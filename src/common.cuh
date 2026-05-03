#pragma once

#include <cublas_v2.h>
#include <cuda_runtime.h>
#include <cusolverDn.h>

#include <cmath>
#include <sstream>
#include <stdexcept>
#include <string>

inline void throw_runtime(const std::string& message) {
    throw std::runtime_error(message);
}

inline void check_cuda(cudaError_t status, const char* expr, const char* file, int line) {
    if (status != cudaSuccess) {
        std::ostringstream oss;
        oss << file << ":" << line << " CUDA error for " << expr << ": " << cudaGetErrorString(status);
        throw_runtime(oss.str());
    }
}

inline void check_cublas(cublasStatus_t status, const char* expr, const char* file, int line) {
    if (status != CUBLAS_STATUS_SUCCESS) {
        std::ostringstream oss;
        oss << file << ":" << line << " cuBLAS error for " << expr << ": status " << static_cast<int>(status);
        throw_runtime(oss.str());
    }
}

inline void check_cusolver(cusolverStatus_t status, const char* expr, const char* file, int line) {
    if (status != CUSOLVER_STATUS_SUCCESS) {
        std::ostringstream oss;
        oss << file << ":" << line << " cuSOLVER error for " << expr << ": status " << static_cast<int>(status);
        throw_runtime(oss.str());
    }
}

#define CHECK_CUDA(expr) check_cuda((expr), #expr, __FILE__, __LINE__)
#define CHECK_CUBLAS(expr) check_cublas((expr), #expr, __FILE__, __LINE__)
#define CHECK_CUSOLVER(expr) check_cusolver((expr), #expr, __FILE__, __LINE__)

template <typename T>
class DeviceBuffer {
public:
    DeviceBuffer() = default;
    explicit DeviceBuffer(size_t count) { allocate(count); }
    ~DeviceBuffer() { release(); }

    DeviceBuffer(const DeviceBuffer&) = delete;
    DeviceBuffer& operator=(const DeviceBuffer&) = delete;

    DeviceBuffer(DeviceBuffer&& other) noexcept {
        ptr_ = other.ptr_;
        count_ = other.count_;
        other.ptr_ = nullptr;
        other.count_ = 0;
    }

    DeviceBuffer& operator=(DeviceBuffer&& other) noexcept {
        if (this != &other) {
            release();
            ptr_ = other.ptr_;
            count_ = other.count_;
            other.ptr_ = nullptr;
            other.count_ = 0;
        }
        return *this;
    }

    void allocate(size_t count) {
        if (count == count_ && ptr_ != nullptr) {
            return;
        }
        release();
        if (count == 0) {
            return;
        }
        CHECK_CUDA(cudaMalloc(&ptr_, count * sizeof(T)));
        count_ = count;
    }

    void release() {
        if (ptr_ != nullptr) {
            cudaFree(ptr_);
            ptr_ = nullptr;
            count_ = 0;
        }
    }

    T* data() { return ptr_; }
    const T* data() const { return ptr_; }
    size_t size() const { return count_; }
    bool empty() const { return ptr_ == nullptr; }

private:
    T* ptr_ = nullptr;
    size_t count_ = 0;
};

class ScopedCudaEvent {
public:
    ScopedCudaEvent() {
        CHECK_CUDA(cudaEventCreate(&start_));
        CHECK_CUDA(cudaEventCreate(&stop_));
    }

    ~ScopedCudaEvent() {
        cudaEventDestroy(start_);
        cudaEventDestroy(stop_);
    }

    template <typename Fn>
    float time(Fn&& fn) {
        CHECK_CUDA(cudaEventRecord(start_));
        fn();
        CHECK_CUDA(cudaEventRecord(stop_));
        CHECK_CUDA(cudaEventSynchronize(stop_));
        float elapsed_ms = 0.0f;
        CHECK_CUDA(cudaEventElapsedTime(&elapsed_ms, start_, stop_));
        return elapsed_ms;
    }

private:
    cudaEvent_t start_{};
    cudaEvent_t stop_{};
};
