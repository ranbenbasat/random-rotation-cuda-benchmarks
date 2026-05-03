cmake_minimum_required(VERSION 3.24)

project(random_rotation_cuda_benchmarks LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 86)

find_package(CUDAToolkit REQUIRED)

add_executable(rotation_bench
    src/benchmark.cu
)

target_include_directories(rotation_bench PRIVATE src)

target_link_libraries(rotation_bench
    PRIVATE
        CUDA::cublas
        CUDA::cusolver
        CUDA::curand
)

target_compile_options(rotation_bench
    PRIVATE
        $<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>
        $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>
)
