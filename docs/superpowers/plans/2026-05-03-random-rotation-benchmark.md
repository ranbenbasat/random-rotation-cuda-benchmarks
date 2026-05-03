# Random Rotation Benchmark Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and run a reproducible CUDA benchmark for three random rotation methods, save figures and summaries, and package the results for GitHub and email.

**Architecture:** A CUDA/C++ benchmark executable provides seeded transform construction, application, inverse checks, and timing. A small Python post-processing script reads the CSV output, computes confidence intervals, and generates plots and a markdown summary.

**Tech Stack:** CUDA 12.6, C++17, cuBLAS, cuSOLVER, Python 3.9, NumPy, SciPy, Matplotlib

---

### Task 1: Scaffold the workspace and build system

**Files:**
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/CMakeLists.txt`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/README.md`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/tests/`

- [ ] Write the build files and project layout.
- [ ] Configure a CUDA build directory.
- [ ] Verify a minimal CUDA target compiles.

### Task 2: Write failing correctness tests first

**Files:**
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/tests/test_random_rotations.py`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/scripts/run_tests.py`

- [ ] Add tests for deterministic seeded outputs.
- [ ] Add tests for norm preservation.
- [ ] Add tests for inverse reconstruction.
- [ ] Run the tests and observe failure before implementation.

### Task 3: Implement the benchmark executable

**Files:**
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/benchmark.cu`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/random_utils.cuh`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/haar_qr.cuh`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/reflector_rotation.cuh`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/src/rht_rotation.cuh`

- [ ] Implement shared timing and CSV output helpers.
- [ ] Implement the full Haar QR builder and apply path.
- [ ] Implement the reflector-based builder, apply path, and inverse path.
- [ ] Implement the randomized Hadamard builder, apply path, and inverse path.
- [ ] Run the tests until they pass.

### Task 4: Post-process benchmark data

**Files:**
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/scripts/plot_results.py`
- Create: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/results/`

- [ ] Run the benchmark sweep.
- [ ] Compute 95% confidence intervals.
- [ ] Write a markdown summary and figures.

### Task 5: Package and hand off

**Files:**
- Modify: `C:/Users/supgo/Documents/Codex/2026-05-03-we-want-to-compare-methods-for-randomly-rotating-input-vectors/README.md`

- [ ] Initialize git and commit the benchmark project.
- [ ] Attempt GitHub publication using the available authenticated route.
- [ ] Email the runtime figures and summary.
