import csv
import math
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy import stats


ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "results" / "runtime_results.csv"
FIGURES_DIR = ROOT / "results" / "figures"
SUMMARY_PATH = ROOT / "results" / "runtime_summary.md"

METHOD_LABELS = {
    "haar_qr": "Haar QR",
    "reflector_chain": "Reflector Chain",
    "rht": "RHT",
}

METHOD_COLORS = {
    "haar_qr": "#d95f02",
    "reflector_chain": "#1b9e77",
    "rht": "#7570b3",
}


def load_rows():
    rows = []
    with CSV_PATH.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            row["dimension"] = int(row["dimension"])
            row["trial"] = int(row["trial"])
            row["time_ms"] = float(row["time_ms"])
            row["batch_repeats"] = int(row.get("batch_repeats", 1))
            rows.append(row)
    return rows


def summarize(rows):
    grouped = defaultdict(list)
    failures = defaultdict(list)
    batch_repeats = defaultdict(list)
    for row in rows:
        key = (row["method"], row["dimension"], row["metric"])
        if row["status"] == "ok":
            grouped[key].append(row["time_ms"])
            batch_repeats[key].append(row["batch_repeats"])
        else:
            failures[key].append(row["note"])

    summaries = []
    for key, values in grouped.items():
        method, dimension, metric = key
        arr = np.array(values, dtype=np.float64)
        n = len(arr)
        mean = float(arr.mean())
        std = float(arr.std(ddof=1)) if n > 1 else 0.0
        if n > 1:
            tcrit = float(stats.t.ppf(0.975, n - 1))
            half_width = tcrit * std / math.sqrt(n)
        else:
            half_width = 0.0
        low = max(0.0, mean - half_width)
        high = mean + half_width
        summaries.append(
            {
                "method": method,
                "dimension": dimension,
                "metric": metric,
                "n": n,
                "mean_ms": mean,
                "std_ms": std,
                "ci95_low_ms": low,
                "ci95_high_ms": high,
                "batch_repeats": int(round(float(np.mean(batch_repeats[key])))),
            }
        )
    return sorted(summaries, key=lambda item: (item["metric"], item["method"], item["dimension"])), failures


def local_exponents(summaries, metric):
    rows = [row for row in summaries if row["metric"] == metric]
    grouped = defaultdict(list)
    for row in rows:
        grouped[row["method"]].append(row)

    exponents = {}
    for method, method_rows in grouped.items():
        method_rows = sorted(method_rows, key=lambda item: item["dimension"])
        adjacent = []
        for left, right in zip(method_rows, method_rows[1:]):
            exponent = math.log(right["mean_ms"] / left["mean_ms"], 2.0) / math.log(
                right["dimension"] / left["dimension"], 2.0
            )
            adjacent.append((right["dimension"], exponent))

        tail_rows = method_rows[-3:] if len(method_rows) >= 3 else method_rows
        fit_exponent = None
        if len(tail_rows) >= 2:
            xs = np.log2([row["dimension"] for row in tail_rows])
            ys = np.log2([row["mean_ms"] for row in tail_rows])
            fit_exponent = float(np.polyfit(xs, ys, 1)[0])

        exponents[method] = {
            "adjacent": adjacent,
            "tail_fit": fit_exponent,
        }
    return exponents


def plot_metric(summaries, metric):
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    plt.figure(figsize=(10, 6))
    metric_rows = [row for row in summaries if row["metric"] == metric]
    for method in ["haar_qr", "reflector_chain", "rht"]:
        rows = [row for row in metric_rows if row["method"] == method]
        if not rows:
            continue
        dims = np.array([row["dimension"] for row in rows], dtype=np.int64)
        means = np.array([row["mean_ms"] for row in rows], dtype=np.float64)
        lows = np.array([row["ci95_low_ms"] for row in rows], dtype=np.float64)
        highs = np.array([row["ci95_high_ms"] for row in rows], dtype=np.float64)
        color = METHOD_COLORS[method]
        plt.plot(dims, means, marker="o", linewidth=2.0, color=color, label=METHOD_LABELS[method])
        plt.fill_between(dims, lows, highs, alpha=0.18, color=color)

    all_dims = sorted({row["dimension"] for row in metric_rows})
    plt.xscale("log", base=2)
    plt.yscale("log")
    plt.xticks(all_dims, [f"$2^{{{int(math.log2(dim))}}}$" for dim in all_dims])
    plt.xlabel("Vector dimension")
    plt.ylabel("Runtime (ms)")
    plt.title(f"{metric.replace('_', ' ').replace('ms', 'ms').title()} with 95% CI")
    plt.grid(True, which="both", linestyle="--", linewidth=0.5, alpha=0.5)
    plt.legend()
    output_path = FIGURES_DIR / f"{metric}.png"
    plt.tight_layout()
    plt.savefig(output_path, dpi=200)
    plt.close()
    return output_path


def write_summary(summaries, failures, figure_paths):
    lines = []
    lines.append("# Random Rotation Benchmark Summary")
    lines.append("")
    lines.append("The tables below report mean runtime in milliseconds with 95% confidence intervals across repeated trials.")
    lines.append("Sub-millisecond paths use batched timing and are divided back down to per-transform runtimes to reduce launch-overhead noise.")
    lines.append("")
    for metric in ["setup_ms", "apply_ms", "end_to_end_ms"]:
        lines.append(f"## {metric}")
        lines.append("")
        lines.append("| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |")
        lines.append("| --- | ---: | ---: | ---: | ---: | ---: |")
        metric_rows = [row for row in summaries if row["metric"] == metric]
        for row in metric_rows:
            lines.append(
                "| "
                f"{METHOD_LABELS[row['method']]} | {row['dimension']} | {row['n']} | {row['batch_repeats']} | "
                f"{row['mean_ms']:.6f} | [{row['ci95_low_ms']:.6f}, {row['ci95_high_ms']:.6f}] |"
            )
        lines.append("")

    lines.append("## Empirical Scaling Exponents")
    lines.append("")
    lines.append("Adjacent exponents use consecutive powers of two. Tail fit uses the largest three available dimensions for that method/metric.")
    lines.append("")
    lines.append("| Method | Metric | Largest Adjacent Exponent | Tail Fit Exponent |")
    lines.append("| --- | --- | ---: | ---: |")
    for metric in ["setup_ms", "apply_ms", "end_to_end_ms"]:
        metric_exponents = local_exponents(summaries, metric)
        for method in ["haar_qr", "reflector_chain", "rht"]:
            values = metric_exponents.get(method, {})
            adjacent = values.get("adjacent", [])
            largest_adjacent = adjacent[-1][1] if adjacent else float("nan")
            tail_fit = values.get("tail_fit")
            lines.append(
                "| "
                f"{METHOD_LABELS[method]} | {metric} | "
                f"{largest_adjacent:.3f} | {tail_fit:.3f} |"
            )
    lines.append("")

    if failures:
        lines.append("## Failures")
        lines.append("")
        for key, notes in sorted(failures.items()):
            method, dimension, metric = key
            lines.append(f"- {METHOD_LABELS.get(method, method)} at d={dimension} for {metric}: {notes[0]}")
        lines.append("")

    lines.append("## Figures")
    lines.append("")
    for path in figure_paths:
        lines.append(f"- `{path.relative_to(ROOT)}`")
    lines.append("")

    SUMMARY_PATH.write_text("\n".join(lines), encoding="utf-8")


def main():
    rows = load_rows()
    summaries, failures = summarize(rows)
    figure_paths = [plot_metric(summaries, metric) for metric in ["setup_ms", "apply_ms", "end_to_end_ms"]]
    write_summary(summaries, failures, figure_paths)


if __name__ == "__main__":
    main()
