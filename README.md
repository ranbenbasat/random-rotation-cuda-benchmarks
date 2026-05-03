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
.\build\Release\rotation_bench.exe --benchmark --min-power 8 --max-power 18 --target-batch-ms 500 --max-batch-repeats 8192 --output results\runtime_results.csv
python scripts/plot_results.py
```

Useful note:

- The benchmark now performs a preflight device-memory check and records explicit `failed` rows instead of crashing when a method state would exceed the available GPU memory budget.

## Current Results

From the included benchmark run:

- The sweep requests dimensions through `d = 262144`.
- On this RTX 3080 benchmark machine, the dense Haar QR path is feasible through `d = 32768` and is skipped at `d >= 65536` because its explicit state exceeds the available GPU memory budget.
- The packed reflector-chain implementation is also feasible through `d = 32768` and is skipped at `d >= 65536` for the same reason.
- The RHT path runs through the full `d = 262144` range.
- At `d = 32768`, `end_to_end_ms` is about `11656.61 ms` for `haar_qr` and `986.78 ms` for `reflector_chain`.
- The large-d empirical end-to-end exponent is now clearly different: about `2.792` for `haar_qr` on the largest three successful points versus about `2.079` for `reflector_chain`.
- At `d = 262144`, the RHT `end_to_end_ms` is about `0.1589 ms`.
- The RHT path remains the fastest overall, but it is a structured orthogonal transform rather than a Haar-uniform rotation, and single-vector GPU timings remain partially launch/occupancy dominated even after batched timing.

See `results/runtime_summary.md` and the PNG figures under `results/figures/` for the complete tables and confidence intervals.
