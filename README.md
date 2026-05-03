# Random Rotation CUDA Benchmarks

This project compares three reproducible random vector rotation methods on an RTX 3080 with native CUDA code:

1. `haar_qr`: build a full Haar-uniform orthogonal matrix from a seeded Gaussian matrix and QR factorization, then apply it with GEMV.
2. `reflector_chain`: build a seeded `O(d^2)` chain of Householder reflectors using Stewart's construction and apply it without materializing the dense matrix.
3. `rht`: build a seeded randomized Hadamard transform using a deterministic Rademacher sign vector and an orthonormal fast Walsh-Hadamard transform.

The benchmark measures:

- `setup_ms`: build the reusable transform state from a seed.
- `apply_ms`: apply the fixed transform to one vector.
- `end_to_end_ms`: setup plus one apply.

All timings are repeated multiple times per dimension and summarized with 95% confidence intervals. Very small sub-millisecond paths are timed in batches and then divided back down to per-transform runtimes so the RHT path is less distorted by kernel-launch overhead.

## Repository Layout

- `src/`: CUDA benchmark implementation
- `tests/`: reproducibility, norm-preservation, and inverse-accuracy checks
- `scripts/plot_results.py`: post-processing for tables and figures
- `results/runtime_results.csv`: raw trial data
- `results/runtime_summary.md`: aggregated summary
- `results/figures/`: generated figures

## Build

```powershell
cmake -S . -B build
cmake --build build --config Release
```

If `cmake` is not on `PATH`, the Visual Studio bundled CMake works too:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe' -S . -B build
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe' --build build --config Release
```

## Test

```powershell
python scripts/run_tests.py
```

## Benchmark

```powershell
.\build\Release\rotation_bench.exe --benchmark --min-power 8 --max-power 18 --target-batch-ms 500 --max-batch-repeats 8192 --memory-cap-bytes 9663676416 --output results\runtime_results.csv
python scripts/plot_results.py
```

Useful note:

- The benchmark now performs a preflight device-memory check and records explicit `failed` rows instead of crashing when a method state would exceed the available GPU memory budget.
- By default, the preflight check uses 90% of `cudaMemGetInfo` free memory. Passing `--memory-cap-bytes` is an explicit override for runs where a larger allocation is intentional; CUDA allocation failures are still caught and recorded as failures.

## Current Results

From the included benchmark run:

- The sweep requests dimensions through `d = 262144`.
- On this RTX 3080 benchmark machine, the dense Haar QR path is feasible through `d = 32768` and is skipped at `d >= 65536` because its explicit state exceeds the available GPU memory budget.
- With an explicit 9 GiB cap, the packed reflector-chain implementation is feasible through `d = 65536` and is skipped at `d >= 131072`.
- The RHT path runs through the full `d = 262144` range.
- At `d = 32768`, `end_to_end_ms` is about `9623.60 ms` for `haar_qr` and `989.40 ms` for `reflector_chain`.
- At `d = 65536`, `reflector_chain` `end_to_end_ms` is about `4017.07 ms`.
- The large-d empirical end-to-end exponent is clearly different: about `2.766` for `haar_qr` on the largest three successful points versus about `2.080` for `reflector_chain`.
- At `d = 262144`, the RHT `end_to_end_ms` is about `0.1564 ms`.
- The RHT path remains the fastest overall, but it is a structured orthogonal transform rather than a Haar-uniform rotation, and single-vector GPU timings remain partially launch/occupancy dominated even after batched timing.

See `results/runtime_summary.md` and the PNG figures under `results/figures/` for the complete tables and confidence intervals.
