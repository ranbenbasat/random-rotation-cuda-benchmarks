# Random Rotation Benchmark Design

**Date:** 2026-05-03

## Goal

Build a CUDA benchmark that compares three reproducible random vector rotation methods on powers-of-two dimensions from `2^8` through `2^14`:

1. Haar-uniform random rotation built from a seeded Gaussian matrix and QR factorization, then applied to a vector.
2. A seeded chain of Householder reflectors that defines a Haar-uniform rotation and applies it in `O(d^2)`.
3. A seeded randomized Hadamard transform (RHT) in `O(d log d)`.

The benchmark should produce repeated runtime measurements, 95% confidence intervals, correctness checks, figures, and an email-ready summary.

## Assumptions

- Use single-precision `float` on device for the main benchmark because the largest matrix path is memory heavy on a 10 GB RTX 3080.
- Reproducibility is defined by a fixed 64-bit seed per method and dimension.
- For every method we measure both:
  - `setup_ms`: build the reusable transform state from a seed.
  - `apply_ms`: apply a previously built transform to one vector.
  - `end_to_end_ms`: setup plus one apply, computed from repeated trials.
- We verify inverse application for reflector and RHT paths. For the full Haar matrix path we verify orthogonality and inverse apply through the explicit matrix.
- If the full Haar path cannot allocate enough memory at the largest size on this GPU, the benchmark records the failure explicitly rather than silently dropping the case.

## Implementation Plan

### CUDA/C++ benchmark core

- A single native CUDA executable owns data generation, correctness checks, and timing.
- Method 1 uses custom Gaussian generation plus cuSOLVER QR to build the explicit orthogonal matrix and cuBLAS GEMV to apply it.
- Method 2 stores seeded Householder reflector parameters and uses custom CUDA kernels for:
  - parallel reflector norm and scaling preparation
  - reflector application with reduction-based dot products
  - reverse-order inverse application
- Method 3 stores a seeded sign vector and optional seeded permutation and uses custom CUDA kernels for:
  - sign flip
  - permutation gather/scatter
  - fast Walsh-Hadamard stages

### Measurement

- Warm up each path before collecting samples.
- Use CUDA events around setup and apply sections.
- Collect multiple trials per dimension and method, then compute mean, standard deviation, and 95% t-intervals.
- Save results as CSV for traceability.

### Validation

- Check norm preservation and inverse reconstruction error against a reference tolerance.
- Use small dimensions in test mode to ensure seeded reproducibility.
- Cross-check reflector and RHT outputs against CPU reference implementations.

### Outputs

- `results/runtime_results.csv`
- `results/runtime_summary.md`
- `results/figures/*.png`
- `README.md` with build, run, and interpretation notes

## Default choices made without further user input

- Local repo name: `random-rotation-cuda-benchmarks`
- Seed schedule: deterministic base seed plus dimension and method offsets
- Trial count target: enough samples for 95% CIs while keeping the total run practical on the available GPU
