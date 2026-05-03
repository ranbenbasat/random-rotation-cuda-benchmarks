#pragma once

#include "common.cuh"
#include "random_utils.cuh"

#include <cmath>
#include <cstdint>

__global__ void fwht_small_kernel(const float* input, float* output, int n) {
    extern __shared__ float scratch[];
    const int tid = threadIdx.x;

    for (int idx = tid; idx < n; idx += blockDim.x) {
        scratch[idx] = input[idx];
    }
    __syncthreads();

    for (int stride = 1; stride < n; stride <<= 1) {
        const int pair_count = n >> 1;
        for (int pair = tid; pair < pair_count; pair += blockDim.x) {
            const int group = pair / stride;
            const int offset = pair % stride;
            const int left = group * (stride << 1) + offset;
            const int right = left + stride;
            const float a = scratch[left];
            const float b = scratch[right];
            scratch[left] = a + b;
            scratch[right] = a - b;
        }
        __syncthreads();
    }

    for (int idx = tid; idx < n; idx += blockDim.x) {
        output[idx] = scratch[idx];
    }
}

__global__ void fwht_stage_kernel(float* values, int n, int stride) {
    const int pair = blockIdx.x * blockDim.x + threadIdx.x;
    const int pair_count = n >> 1;
    if (pair >= pair_count) {
        return;
    }
    const int group = pair / stride;
    const int offset = pair % stride;
    const int left = group * (stride << 1) + offset;
    const int right = left + stride;
    const float a = values[left];
    const float b = values[right];
    values[left] = a + b;
    values[right] = a - b;
}

inline void launch_fwht(float* values, DeviceBuffer<float>& scratch, int n) {
    if (n <= 1024) {
        const int threads = (n < 256) ? n : 256;
        fwht_small_kernel<<<1, threads, static_cast<size_t>(n) * sizeof(float)>>>(values, scratch.data(), n);
        CHECK_CUDA(cudaGetLastError());
        CHECK_CUDA(cudaMemcpy(values, scratch.data(), static_cast<size_t>(n) * sizeof(float), cudaMemcpyDeviceToDevice));
        return;
    }

    for (int stride = 1; stride < n; stride <<= 1) {
        const int pair_count = n >> 1;
        const int threads = 256;
        const int blocks = (pair_count + threads - 1) / threads;
        fwht_stage_kernel<<<blocks, threads>>>(values, n, stride);
        CHECK_CUDA(cudaGetLastError());
    }
}

struct RhtRotation {
    int n = 0;
    DeviceBuffer<float> signs;
    DeviceBuffer<float> scratch;

    explicit RhtRotation(int dimension) : n(dimension) {}

    void build(uint64_t seed) {
        signs.allocate(static_cast<size_t>(n));
        scratch.allocate(static_cast<size_t>(n));
        launch_fill_signs(signs.data(), static_cast<size_t>(n), seed);
    }

    void apply(const float* input, float* output) {
        CHECK_CUDA(cudaMemcpy(output, input, static_cast<size_t>(n) * sizeof(float), cudaMemcpyDeviceToDevice));
        launch_multiply_signs(output, signs.data(), n);
        launch_fwht(output, scratch, n);
        launch_scale(output, n, 1.0f / sqrtf(static_cast<float>(n)));
    }

    void inverse(const float* input, float* output) {
        CHECK_CUDA(cudaMemcpy(output, input, static_cast<size_t>(n) * sizeof(float), cudaMemcpyDeviceToDevice));
        launch_fwht(output, scratch, n);
        launch_scale(output, n, 1.0f / sqrtf(static_cast<float>(n)));
        launch_multiply_signs(output, signs.data(), n);
    }
};
