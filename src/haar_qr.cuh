#pragma once

#include "common.cuh"
#include "random_utils.cuh"

#include <algorithm>
#include <cstdint>

struct HaarQrRotation {
    int n = 0;
    DeviceBuffer<float> matrix;
    DeviceBuffer<float> tau;
    DeviceBuffer<float> work;
    DeviceBuffer<float> diag_signs;
    DeviceBuffer<int> info;

    explicit HaarQrRotation(int dimension) : n(dimension) {}

    void build(cusolverDnHandle_t solver_handle, uint64_t seed) {
        const size_t matrix_elements = static_cast<size_t>(n) * static_cast<size_t>(n);
        matrix.allocate(matrix_elements);
        tau.allocate(static_cast<size_t>(n));
        diag_signs.allocate(static_cast<size_t>(n));
        info.allocate(1);

        launch_fill_normals(matrix.data(), matrix_elements, seed);

        int geqrf_lwork = 0;
        int orgqr_lwork = 0;
        CHECK_CUSOLVER(cusolverDnSgeqrf_bufferSize(
            solver_handle,
            n,
            n,
            matrix.data(),
            n,
            &geqrf_lwork));
        CHECK_CUSOLVER(cusolverDnSorgqr_bufferSize(
            solver_handle,
            n,
            n,
            n,
            matrix.data(),
            n,
            tau.data(),
            &orgqr_lwork));

        work.allocate(static_cast<size_t>(std::max(geqrf_lwork, orgqr_lwork)));

        CHECK_CUSOLVER(cusolverDnSgeqrf(
            solver_handle,
            n,
            n,
            matrix.data(),
            n,
            tau.data(),
            work.data(),
            geqrf_lwork,
            info.data()));
        CHECK_CUDA(cudaDeviceSynchronize());
        check_info();

        {
            const int threads = 256;
            const int blocks = (n + threads - 1) / threads;
            extract_qr_diag_signs_kernel<<<blocks, threads>>>(matrix.data(), diag_signs.data(), n);
            CHECK_CUDA(cudaGetLastError());
        }

        CHECK_CUSOLVER(cusolverDnSorgqr(
            solver_handle,
            n,
            n,
            n,
            matrix.data(),
            n,
            tau.data(),
            work.data(),
            orgqr_lwork,
            info.data()));
        CHECK_CUDA(cudaDeviceSynchronize());
        check_info();

        {
            const size_t total = matrix_elements;
            const int threads = 256;
            const int blocks = static_cast<int>((total + threads - 1ULL) / threads);
            apply_column_signs_kernel<<<blocks, threads>>>(matrix.data(), diag_signs.data(), n);
            CHECK_CUDA(cudaGetLastError());
        }
    }

    void apply(cublasHandle_t cublas_handle, const float* input, float* output) const {
        static const float alpha = 1.0f;
        static const float beta = 0.0f;
        CHECK_CUBLAS(cublasSgemv(
            cublas_handle,
            CUBLAS_OP_N,
            n,
            n,
            &alpha,
            matrix.data(),
            n,
            input,
            1,
            &beta,
            output,
            1));
    }

    void inverse(cublasHandle_t cublas_handle, const float* input, float* output) const {
        static const float alpha = 1.0f;
        static const float beta = 0.0f;
        CHECK_CUBLAS(cublasSgemv(
            cublas_handle,
            CUBLAS_OP_T,
            n,
            n,
            &alpha,
            matrix.data(),
            n,
            input,
            1,
            &beta,
            output,
            1));
    }

private:
    void check_info() const {
        int host_info = 0;
        CHECK_CUDA(cudaMemcpy(&host_info, info.data(), sizeof(int), cudaMemcpyDeviceToHost));
        if (host_info != 0) {
            throw_runtime("cuSOLVER QR step failed with devInfo=" + std::to_string(host_info));
        }
    }
};
