import csv
import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD_DIR = ROOT / "build"

def find_cmake() -> str:
    candidates = [
        "cmake",
        r"C:\Program Files\CMake\bin\cmake.exe",
        (
            r"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE"
            r"\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
        ),
    ]
    for candidate in candidates:
        try:
            completed = subprocess.run(
                [candidate, "--version"],
                check=True,
                capture_output=True,
                text=True,
            )
        except (OSError, subprocess.CalledProcessError):
            continue
        if "cmake version" in completed.stdout.lower():
            return candidate
    raise FileNotFoundError("cmake executable not found")


CMAKE_BIN = find_cmake()

def executable_path() -> Path:
    release_path = BUILD_DIR / "Release" / "rotation_bench.exe"
    if release_path.exists():
        return release_path
    return BUILD_DIR / "rotation_bench.exe"


def configure_and_build():
    BUILD_DIR.mkdir(exist_ok=True)
    subprocess.run(
        [CMAKE_BIN, "-S", str(ROOT), "-B", str(BUILD_DIR)],
        check=True,
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        [CMAKE_BIN, "--build", str(BUILD_DIR), "--config", "Release"],
        check=True,
        cwd=ROOT,
        capture_output=True,
        text=True,
    )


class RandomRotationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        configure_and_build()

    def run_self_test(self):
        completed = subprocess.run(
            [str(executable_path()), "--self-test"],
            check=True,
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        return json.loads(completed.stdout)

    def test_seeded_outputs_are_reproducible(self):
        payload = self.run_self_test()
        for method, info in payload["methods"].items():
            self.assertTrue(info["reproducible"], method)

    def test_transforms_preserve_norm(self):
        payload = self.run_self_test()
        for method, info in payload["methods"].items():
            self.assertLess(info["relative_norm_error"], 1e-4, method)

    def test_inverse_reconstruction_is_accurate(self):
        payload = self.run_self_test()
        for method, info in payload["methods"].items():
            self.assertLess(info["inverse_relative_error"], 1e-4, method)

    def test_benchmark_accepts_dimension_range_and_target_batch_options(self):
        output_path = ROOT / "build" / "test_runtime_results.csv"
        if output_path.exists():
            output_path.unlink()

        subprocess.run(
            [
                str(executable_path()),
                "--benchmark",
                "--min-power",
                "8",
                "--max-power",
                "8",
                "--target-batch-ms",
                "1",
                "--output",
                str(output_path),
            ],
            check=True,
            cwd=ROOT,
            capture_output=True,
            text=True,
        )

        with output_path.open(newline="", encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            dimensions = {int(row["dimension"]) for row in reader}

        self.assertEqual(dimensions, {256})
        output_path.unlink()


if __name__ == "__main__":
    unittest.main()
