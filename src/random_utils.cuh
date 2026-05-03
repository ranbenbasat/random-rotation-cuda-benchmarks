#pragma once

#include "common.cuh"

#include <cstdint>

constexpr float kPi = 3.14159265358979323846f;

__host__ __device__ inline uint64_t splitmix64(uint64_t x) {
    x += 0x9e3779b97f4a7c15ULL;
    x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ULL;
    x = (x ^ (x >> 27)) * 0x94d049bb133111ebULL;
    return x ^ (x >> 31);
}

__host__ __device__ inline float uniform_open01(uint64_t x) {
    constexpr double denom = 1.0 / 9007199254740992.0;
    double value = static_cast<double>((x >> 11) + 1ULL) * denom;
    if (value >= 1.0) {
        value = 0.9999999999999999;
    }
    return static_cast<float>(value);
}

__global__ void fill_normal_kernel(float* output, size_t count, uint64_t seed) {
    const size_t pair_index = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const size_t first = pair_index * 2;
    if (first >= count) {
        return;
    }

    const uint64_t a = splitmix64(seed ^ (0x6a09e667f3bcc909ULL + pair_index * 2ULL));
    const uint64_t b = splitmix64(seed ^ (0xbb67ae8584caa73bULL + pair_index * 2ULL + 1ULL));

    const float u1 = uniform_open01(a);
    const float u2 = uniform_open01(b);
    const float radius = sqrtf(-2.0f * logf(u1));
    const float angle = 2.0f * kPi * u2;
    float sin_angle = 0.0f;
    float cos_angle = 0.0f;
    sincosf(angle, &sin_angle, &cos_angle);

    output[first] = radius * cos_angle;
    if (first + 1 < count) {
        output[first + 1] = radius * sin_angle;
    }
}

__global__ void fill_sign_kernel(float* output, size_t count, uint64_t seed) {
    const size_t idx = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    if (idx >= count) {
        return;
    }
    const uint64_t value = splitmix64(seed ^ (0x3c6ef372fe94f82aULL + idx));
    output[idx] = (value & 1ULL) ? 1.0f : -1.0f;
}

__global__ void scale_vector_kernel(float* values, int count, float scale) {
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < count) {
        values[idx] *= scale;
    }
}

__global__ void multiply_signs_kernel(float* values, const float* signs, int count) {
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < count) {
        values[idx] *= signs[idx];
    }
}

__global__ void extract_qr_diag_signs_kernel(const float* qr_matrix, float* diag_signs, int n) {
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        const float value = qr_matrix[idx + idx * n];
        diag_signs[idx] = (value >= 0.0f) ? 1.0f : -1.0f;
    }
}

__global__ void apply_column_signs_kernel(float* matrix, const float* diag_signs, int n) {
    const size_t idx = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    const size_t total = static_cast<size_t>(n) * static_cast<size_t>(n);
    if (idx >= total) {
        return;
    }
    const int col = static_cast<int>(idx / n);
    matrix[idx] *= diag_signs[col];
}

inline void launch_fill_normals(float* output, size_t count, uint64_t seed) {
    const int threads = 256;
    const int blocks = static_cast<int>((count + (threads * 2ULL) - 1ULL) / (threads * 2ULL));
    fill_normal_kernel<<<blocks, threads>>>(output, count, seed);
    CHECK_CUDA(cudaGetLastError());
}

inline void launch_fill_signs(float* output, size_t count, uint64_t seed) {
    const int threads = 256;
    const int blocks = static_cast<int>((count + threads - 1ULL) / threads);
    fill_sign_kernel<<<blocks, threads>>>(output, count, seed);
    CHECK_CUDA(cudaGetLastError());
}

inline void launch_scale(float* values, int count, float scale) {
    const int threads = 256;
    const int blocks = (count + threads - 1) / threads;
    scale_vector_kernel<<<blocks, threads>>>(values, count, scale);
    CHECK_CUDA(cudaGetLastError());
}

inline void launch_multiply_signs(float* values, const float* signs, int count) {
    const int threads = 256;
    const int blocks = (count + threads - 1) / threads;
    multiply_signs_kernel<<<blocks, threads>>>(values, signs, count);
    CHECK_CUDA(cudaGetLastError());
}
