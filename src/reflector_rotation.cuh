#pragma once

#include "common.cuh"
#include "random_utils.cuh"

#include <cstdint>

__host__ __device__ inline size_t reflector_offset(int n, int reflector_index) {
    return static_cast<size_t>(reflector_index) * static_cast<size_t>(n) -
           static_cast<size_t>(reflector_index) * static_cast<size_t>(reflector_index - 1) / 2ULL;
}

__global__ void finalize_reflectors_kernel(float* packed, float* beta, float* row_signs, int n) {
    const int reflector_index = blockIdx.x;
    if (reflector_index >= n - 1) {
        return;
    }

    const int len = n - reflector_index;
    const size_t offset = reflector_offset(n, reflector_index);
    float* vector = packed + offset;

    __shared__ float shared_sum[256];
    const int tid = threadIdx.x;

    float local_sum = 0.0f;
    for (int idx = tid; idx < len; idx += blockDim.x) {
        const float value = vector[idx];
        local_sum += value * value;
    }
    shared_sum[tid] = local_sum;
    __syncthreads();

    for (int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
        if (tid < stride) {
            shared_sum[tid] += shared_sum[tid + stride];
        }
        __syncthreads();
    }

    if (tid == 0) {
        float norm_value = sqrtf(shared_sum[0]);
        float sign_value = (vector[0] >= 0.0f) ? 1.0f : -1.0f;
        norm_value *= sign_value;
        row_signs[reflector_index] = -sign_value;
        vector[0] += norm_value;
        float beta_value = norm_value * vector[0];
        if (fabsf(beta_value) < 1e-20f) {
            beta_value = 1e-20f;
        }
        beta[reflector_index] = beta_value;
    }
}

__global__ void set_last_row_sign_kernel(float* row_signs, int n, uint64_t seed) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        const uint64_t raw = splitmix64(seed ^ 0xdbe6d5d5fe4cce2fULL);
        row_signs[n - 1] = (raw & 1ULL) ? 1.0f : -1.0f;
    }
}

template <bool Inverse>
__global__ void apply_reflector_chain_kernel(
    const float* packed,
    const float* beta,
    const float* row_signs,
    const float* input,
    float* output,
    int n) {
    __shared__ float shared_scalar[256];
    const int tid = threadIdx.x;

    for (int idx = tid; idx < n; idx += blockDim.x) {
        output[idx] = input[idx];
    }
    __syncthreads();

    if constexpr (Inverse) {
        for (int idx = tid; idx < n; idx += blockDim.x) {
            output[idx] *= row_signs[idx];
        }
        __syncthreads();
    }

    const int begin = Inverse ? 0 : n - 2;
    const int end = Inverse ? n - 1 : -1;
    const int step = Inverse ? 1 : -1;

    for (int reflector_index = begin; reflector_index != end; reflector_index += step) {
        const int len = n - reflector_index;
        const size_t offset = reflector_offset(n, reflector_index);
        const float* vector = packed + offset;
        float local_dot = 0.0f;
        for (int idx = tid; idx < len; idx += blockDim.x) {
            local_dot += vector[idx] * output[reflector_index + idx];
        }
        shared_scalar[tid] = local_dot;
        __syncthreads();

        for (int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
            if (tid < stride) {
                shared_scalar[tid] += shared_scalar[tid + stride];
            }
            __syncthreads();
        }

        const float factor = shared_scalar[0] / beta[reflector_index];
        for (int idx = tid; idx < len; idx += blockDim.x) {
            output[reflector_index + idx] -= vector[idx] * factor;
        }
        __syncthreads();
    }

    if constexpr (!Inverse) {
        for (int idx = tid; idx < n; idx += blockDim.x) {
            output[idx] *= row_signs[idx];
        }
    }
}

struct ReflectorRotation {
    int n = 0;
    DeviceBuffer<float> packed;
    DeviceBuffer<float> beta;
    DeviceBuffer<float> row_signs;

    explicit ReflectorRotation(int dimension) : n(dimension) {}

    void build(uint64_t seed) {
        const size_t packed_size = static_cast<size_t>(n) * static_cast<size_t>(n + 1) / 2ULL - 1ULL;
        packed.allocate(packed_size);
        beta.allocate(static_cast<size_t>(n - 1));
        row_signs.allocate(static_cast<size_t>(n));

        launch_fill_normals(packed.data(), packed_size, seed);
        finalize_reflectors_kernel<<<n - 1, 256>>>(packed.data(), beta.data(), row_signs.data(), n);
        CHECK_CUDA(cudaGetLastError());
        set_last_row_sign_kernel<<<1, 1>>>(row_signs.data(), n, seed);
        CHECK_CUDA(cudaGetLastError());
    }

    void apply(const float* input, float* output) const {
        apply_reflector_chain_kernel<false><<<1, 256>>>(packed.data(), beta.data(), row_signs.data(), input, output, n);
        CHECK_CUDA(cudaGetLastError());
    }

    void inverse(const float* input, float* output) const {
        apply_reflector_chain_kernel<true><<<1, 256>>>(packed.data(), beta.data(), row_signs.data(), input, output, n);
        CHECK_CUDA(cudaGetLastError());
    }
};
