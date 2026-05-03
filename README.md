# Random Rotation CUDA Benchmarks

This project compares three reproducible random vector rotation methods on an RTX 3080 with native CUDA code:

1. `haar_qr`: build a full Haar-uniform orthogonal matrix from a seeded Gaussian matrix and QR factorization, then apply it with GEMV.
2. `reflector_chain`: build a seeded `O(d^2)` chain of Householder reflectors using Stewart's construction and apply it without materializing the dense matrix.
3. `rht`: build a seeded randomized Hadamard transform using a deterministic Rademacher sign vector and an orthonormal fast Walsh-Hadamard transform.

The benchmark measures:

- `setup_ms`: build the reusable transform state from a seed.
- `apply_ms`: apply the fixed transform to one vector.
- `end_to_end_ms`: setup plus one apply.

All timings are repeated multiple times per dimension and summarized with 95% confidence intervals.

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
.\build\Release\rotation_bench.exe --benchmark --output results\runtime_results.csv
python scripts/plot_results.py
```

## Current Results

From the included benchmark run:

- At `d = 16384`, `end_to_end_ms` was about `1017.80 ms` for `haar_qr`, `223.10 ms` for `reflector_chain`, and `0.109 ms` for `rht`.
- At `d = 16384`, `apply_ms` alone was about `1.554 ms` for `haar_qr`, `219.41 ms` for `reflector_chain`, and `0.104 ms` for `rht`.
- The dense Haar path has by far the highest setup cost but a much faster apply than the reflector chain once the matrix is built.
- The RHT path is the fastest overall, but it is a structured orthogonal transform rather than a Haar-uniform rotation.

See `results/runtime_summary.md` and the PNG figures under `results/figures/` for the complete tables and confidence intervals.
