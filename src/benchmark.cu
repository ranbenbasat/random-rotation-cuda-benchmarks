#include "common.cuh"
#include "haar_qr.cuh"
#include "random_utils.cuh"
#include "reflector_rotation.cuh"
#include "rht_rotation.cuh"

#include <algorithm>
#include <array>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <limits>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>

namespace {

struct MethodSelfTest {
    bool reproducible = false;
    float relative_norm_error = 0.0f;
    float inverse_relative_error = 0.0f;
};

struct TrialRecord {
    std::string method;
    int dimension = 0;
    std::string metric;
    int trial = 0;
    float time_ms = 0.0f;
    int batch_repeats = 1;
    std::string status = "ok";
    std::string note;
};

struct BenchmarkConfig {
    std::string csv_path = "results/runtime_results.csv";
    int warmup_trials = 2;
    int min_power = 8;
    int max_power = 15;
    float target_batch_ms = 10.0f;
    int max_batch_repeats = 256;
};

uint64_t compose_seed(uint64_t base_seed, int dimension, uint64_t method_tag, uint64_t extra = 0) {
    return splitmix64(base_seed ^ (static_cast<uint64_t>(dimension) << 20) ^ method_tag ^ extra);
}

std::vector<float> copy_device_vector(const DeviceBuffer<float>& buffer, int n) {
    std::vector<float> host(static_cast<size_t>(n));
    CHECK_CUDA(cudaMemcpy(host.data(), buffer.data(), static_cast<size_t>(n) * sizeof(float), cudaMemcpyDeviceToHost));
    return host;
}

float l2_norm(const std::vector<float>& values) {
    double accum = 0.0;
    for (float value : values) {
        accum += static_cast<double>(value) * static_cast<double>(value);
    }
    return static_cast<float>(std::sqrt(accum));
}

float relative_error(const std::vector<float>& a, const std::vector<float>& b) {
    double diff = 0.0;
    double denom = 0.0;
    for (size_t i = 0; i < a.size(); ++i) {
        const double delta = static_cast<double>(a[i]) - static_cast<double>(b[i]);
        diff += delta * delta;
        denom += static_cast<double>(a[i]) * static_cast<double>(a[i]);
    }
    return static_cast<float>(std::sqrt(diff) / std::max(1e-12, std::sqrt(denom)));
}

template <typename Rotation, typename BuildFn, typename ApplyFn, typename InverseFn>
MethodSelfTest evaluate_method(
    Rotation& rotation,
    BuildFn&& build_fn,
    ApplyFn&& apply_fn,
    InverseFn&& inverse_fn,
    uint64_t seed,
    int n) {
    DeviceBuffer<float> input(static_cast<size_t>(n));
    DeviceBuffer<float> output_a(static_cast<size_t>(n));
    DeviceBuffer<float> output_b(static_cast<size_t>(n));
    DeviceBuffer<float> restored(static_cast<size_t>(n));

    launch_fill_normals(input.data(), static_cast<size_t>(n), compose_seed(seed, n, 0x12345678ULL));
    CHECK_CUDA(cudaDeviceSynchronize());

    build_fn(rotation, seed);
    apply_fn(rotation, input.data(), output_a.data());
    inverse_fn(rotation, output_a.data(), restored.data());
    CHECK_CUDA(cudaDeviceSynchronize());

    build_fn(rotation, seed);
    apply_fn(rotation, input.data(), output_b.data());
    CHECK_CUDA(cudaDeviceSynchronize());

    std::vector<float> host_input = copy_device_vector(input, n);
    std::vector<float> host_output_a = copy_device_vector(output_a, n);
    std::vector<float> host_output_b = copy_device_vector(output_b, n);
    std::vector<float> host_restored = copy_device_vector(restored, n);

    const float input_norm = l2_norm(host_input);
    const float output_norm = l2_norm(host_output_a);

    MethodSelfTest result;
    result.reproducible = relative_error(host_output_a, host_output_b) < 1e-6f;
    result.relative_norm_error = std::fabs(output_norm - input_norm) / std::max(1e-12f, input_norm);
    result.inverse_relative_error = relative_error(host_input, host_restored);
    return result;
}

std::string run_self_test() {
    constexpr int n = 256;
    constexpr uint64_t base_seed = 0x42f00d1234ULL;

    cublasHandle_t cublas_handle = nullptr;
    cusolverDnHandle_t solver_handle = nullptr;
    CHECK_CUBLAS(cublasCreate(&cublas_handle));
    CHECK_CUSOLVER(cusolverDnCreate(&solver_handle));

    MethodSelfTest haar_test;
    MethodSelfTest reflector_test;
    MethodSelfTest rht_test;

    {
        HaarQrRotation rotation(n);
        haar_test = evaluate_method(
            rotation,
            [&](HaarQrRotation& instance, uint64_t seed) { instance.build(solver_handle, compose_seed(seed, n, 0xa11ceULL)); },
            [&](HaarQrRotation& instance, const float* in, float* out) { instance.apply(cublas_handle, in, out); },
            [&](HaarQrRotation& instance, const float* in, float* out) { instance.inverse(cublas_handle, in, out); },
            base_seed,
            n);
    }

    {
        ReflectorRotation rotation(n);
        reflector_test = evaluate_method(
            rotation,
            [&](ReflectorRotation& instance, uint64_t seed) { instance.build(compose_seed(seed, n, 0xb22dfULL)); },
            [&](ReflectorRotation& instance, const float* in, float* out) { instance.apply(in, out); },
            [&](ReflectorRotation& instance, const float* in, float* out) { instance.inverse(in, out); },
            base_seed,
            n);
    }

    {
        RhtRotation rotation(n);
        rht_test = evaluate_method(
            rotation,
            [&](RhtRotation& instance, uint64_t seed) { instance.build(compose_seed(seed, n, 0xc33efULL)); },
            [&](RhtRotation& instance, const float* in, float* out) { instance.apply(in, out); },
            [&](RhtRotation& instance, const float* in, float* out) { instance.inverse(in, out); },
            base_seed,
            n);
    }

    CHECK_CUBLAS(cublasDestroy(cublas_handle));
    CHECK_CUSOLVER(cusolverDnDestroy(solver_handle));

    std::ostringstream oss;
    oss << std::fixed << std::setprecision(8);
    oss << "{";
    oss << "\"methods\":{";
    oss << "\"haar_qr\":{\"reproducible\":" << (haar_test.reproducible ? "true" : "false")
        << ",\"relative_norm_error\":" << haar_test.relative_norm_error
        << ",\"inverse_relative_error\":" << haar_test.inverse_relative_error << "},";
    oss << "\"reflector_chain\":{\"reproducible\":" << (reflector_test.reproducible ? "true" : "false")
        << ",\"relative_norm_error\":" << reflector_test.relative_norm_error
        << ",\"inverse_relative_error\":" << reflector_test.inverse_relative_error << "},";
    oss << "\"rht\":{\"reproducible\":" << (rht_test.reproducible ? "true" : "false")
        << ",\"relative_norm_error\":" << rht_test.relative_norm_error
        << ",\"inverse_relative_error\":" << rht_test.inverse_relative_error << "}";
    oss << "}}";
    return oss.str();
}

int choose_trial_count(const std::string& method, int dimension) {
    if (method == "haar_qr") {
        if (dimension >= 32768) {
            return 3;
        }
        if (dimension >= 16384) {
            return 4;
        }
        if (dimension >= 8192) {
            return 5;
        }
        if (dimension >= 4096) {
            return 6;
        }
        return 8;
    }
    if (method == "reflector_chain") {
        if (dimension >= 32768) {
            return 8;
        }
        if (dimension >= 16384) {
            return 10;
        }
        return 12;
    }
    if (dimension >= 32768) {
        return 12;
    }
    return 16;
}

std::vector<int> build_dimensions(const BenchmarkConfig& config) {
    if (config.min_power < 1 || config.max_power < config.min_power || config.max_power >= 31) {
        throw_runtime("Invalid power range for benchmark dimensions.");
    }

    std::vector<int> dimensions;
    for (int power = config.min_power; power <= config.max_power; ++power) {
        dimensions.push_back(1 << power);
    }
    return dimensions;
}

template <typename Fn>
int choose_batch_repeats(
    ScopedCudaEvent& timer,
    float target_batch_ms,
    int max_batch_repeats,
    Fn&& fn) {
    if (target_batch_ms <= 0.0f) {
        return 1;
    }
    const float single_ms = timer.time([&]() { fn(0); });
    const float clamped_single_ms = std::max(single_ms, 1e-6f);
    const int suggested = static_cast<int>(std::ceil(target_batch_ms / clamped_single_ms));
    return std::max(1, std::min(max_batch_repeats, suggested));
}

template <typename Fn>
float time_average_ms(
    ScopedCudaEvent& timer,
    int repeats,
    Fn&& fn) {
    const float total_ms = timer.time([&]() {
        for (int repeat = 0; repeat < repeats; ++repeat) {
            fn(repeat);
        }
    });
    return total_ms / static_cast<float>(repeats);
}

template <typename Rotation, typename BuildFn, typename ApplyFn>
void benchmark_method(
    std::vector<TrialRecord>& records,
    const std::string& method,
    int dimension,
    const BenchmarkConfig& config,
    uint64_t base_seed,
    DeviceBuffer<float>& input,
    DeviceBuffer<float>& output,
    Rotation& rotation,
    BuildFn&& build_fn,
    ApplyFn&& apply_fn) {
    ScopedCudaEvent timer;
    const int trials = choose_trial_count(method, dimension);
    const int warmups = config.warmup_trials;

    try {
        for (int warmup = 0; warmup < warmups; ++warmup) {
            build_fn(rotation, compose_seed(base_seed, dimension, 0xfedcbaULL, static_cast<uint64_t>(warmup)));
            apply_fn(rotation, input.data(), output.data());
            CHECK_CUDA(cudaDeviceSynchronize());
        }

        const int setup_repeats = choose_batch_repeats(
            timer,
            config.target_batch_ms,
            config.max_batch_repeats,
            [&](int repeat) {
                build_fn(rotation, compose_seed(base_seed, dimension, 0xabc000ULL, static_cast<uint64_t>(repeat)));
            });

        build_fn(rotation, compose_seed(base_seed, dimension, 0xdef000ULL));
        const int apply_repeats = choose_batch_repeats(
            timer,
            config.target_batch_ms,
            config.max_batch_repeats,
            [&](int) { apply_fn(rotation, input.data(), output.data()); });

        const int end_to_end_repeats = choose_batch_repeats(
            timer,
            config.target_batch_ms,
            config.max_batch_repeats,
            [&](int repeat) {
                build_fn(rotation, compose_seed(base_seed, dimension, 0xeee000ULL, static_cast<uint64_t>(repeat)));
                apply_fn(rotation, input.data(), output.data());
            });

        for (int trial = 0; trial < trials; ++trial) {
            const float setup_ms = time_average_ms(
                timer,
                setup_repeats,
                [&](int repeat) {
                    const uint64_t seed = compose_seed(
                        base_seed,
                        dimension,
                        0x13579bULL + static_cast<uint64_t>(trial),
                        static_cast<uint64_t>(trial) * 4096ULL + static_cast<uint64_t>(repeat));
                    build_fn(rotation, seed);
                });
            records.push_back({method, dimension, "setup_ms", trial, setup_ms, setup_repeats, "ok", ""});

            build_fn(rotation, compose_seed(base_seed, dimension, 0x2468acULL, static_cast<uint64_t>(trial)));
            const float apply_ms = time_average_ms(
                timer,
                apply_repeats,
                [&](int) { apply_fn(rotation, input.data(), output.data()); });
            records.push_back({method, dimension, "apply_ms", trial, apply_ms, apply_repeats, "ok", ""});

            const float end_to_end_ms = time_average_ms(
                timer,
                end_to_end_repeats,
                [&](int repeat) {
                    const uint64_t seed = compose_seed(
                        base_seed,
                        dimension,
                        0x987654ULL + static_cast<uint64_t>(trial),
                        static_cast<uint64_t>(trial) * 4096ULL + static_cast<uint64_t>(repeat));
                    build_fn(rotation, seed);
                    apply_fn(rotation, input.data(), output.data());
                });
            records.push_back({method, dimension, "end_to_end_ms", trial, end_to_end_ms, end_to_end_repeats, "ok", ""});
        }
    } catch (const std::exception& ex) {
        for (const std::string& metric : {"setup_ms", "apply_ms", "end_to_end_ms"}) {
            records.push_back({method, dimension, metric, 0, 0.0f, 1, "failed", ex.what()});
        }
    }
}

void ensure_parent_directory(const std::string& path) {
    const size_t slash = path.find_last_of("/\\");
    if (slash == std::string::npos) {
        return;
    }
    const std::string parent = path.substr(0, slash);
    if (!parent.empty()) {
        std::string command = "if not exist \"" + parent + "\" mkdir \"" + parent + "\"";
        if (std::system(command.c_str()) != 0) {
            throw_runtime("Failed to create output directory: " + parent);
        }
    }
}

void write_csv(const std::string& csv_path, const std::vector<TrialRecord>& records) {
    ensure_parent_directory(csv_path);
    std::ofstream out(csv_path, std::ios::trunc);
    if (!out) {
        throw_runtime("Unable to open CSV output: " + csv_path);
    }
    out << "method,dimension,metric,trial,time_ms,batch_repeats,status,note\n";
    for (const TrialRecord& record : records) {
        std::string note = record.note;
        std::replace(note.begin(), note.end(), ',', ';');
        std::replace(note.begin(), note.end(), '\n', ' ');
        out << record.method << ','
            << record.dimension << ','
            << record.metric << ','
            << record.trial << ','
            << std::fixed << std::setprecision(6) << record.time_ms << ','
            << record.batch_repeats << ','
            << record.status << ','
            << note << '\n';
    }
}

void run_benchmark(const BenchmarkConfig& config) {
    constexpr uint64_t base_seed = 0x91f2e7d4c3b5a601ULL;
    const std::vector<int> dimensions = build_dimensions(config);

    cublasHandle_t cublas_handle = nullptr;
    cusolverDnHandle_t solver_handle = nullptr;
    CHECK_CUBLAS(cublasCreate(&cublas_handle));
    CHECK_CUSOLVER(cusolverDnCreate(&solver_handle));

    std::vector<TrialRecord> records;

    for (int dimension : dimensions) {
        DeviceBuffer<float> input(static_cast<size_t>(dimension));
        DeviceBuffer<float> output(static_cast<size_t>(dimension));
        launch_fill_normals(input.data(), static_cast<size_t>(dimension), compose_seed(base_seed, dimension, 0x4444ULL));
        CHECK_CUDA(cudaDeviceSynchronize());

        {
            HaarQrRotation rotation(dimension);
            benchmark_method(
                records,
                "haar_qr",
                dimension,
                config,
                base_seed,
                input,
                output,
                rotation,
                [&](HaarQrRotation& instance, uint64_t seed) { instance.build(solver_handle, compose_seed(seed, dimension, 0xa11ceULL)); },
                [&](HaarQrRotation& instance, const float* in, float* out) { instance.apply(cublas_handle, in, out); });
        }

        {
            ReflectorRotation rotation(dimension);
            benchmark_method(
                records,
                "reflector_chain",
                dimension,
                config,
                base_seed,
                input,
                output,
                rotation,
                [&](ReflectorRotation& instance, uint64_t seed) { instance.build(compose_seed(seed, dimension, 0xb22dfULL)); },
                [&](ReflectorRotation& instance, const float* in, float* out) { instance.apply(in, out); });
        }

        {
            RhtRotation rotation(dimension);
            benchmark_method(
                records,
                "rht",
                dimension,
                config,
                base_seed,
                input,
                output,
                rotation,
                [&](RhtRotation& instance, uint64_t seed) { instance.build(compose_seed(seed, dimension, 0xc33efULL)); },
                [&](RhtRotation& instance, const float* in, float* out) { instance.apply(in, out); });
        }
    }

    write_csv(config.csv_path, records);

    CHECK_CUBLAS(cublasDestroy(cublas_handle));
    CHECK_CUSOLVER(cusolverDnDestroy(solver_handle));
}

}  // namespace

int main(int argc, char** argv) {
    try {
        std::string mode = "--benchmark";
        BenchmarkConfig config;

        for (int i = 1; i < argc; ++i) {
            const std::string arg = argv[i];
            if (arg == "--self-test") {
                mode = "--self-test";
            } else if (arg == "--benchmark") {
                mode = "--benchmark";
            } else if (arg == "--output" && i + 1 < argc) {
                config.csv_path = argv[++i];
            } else if (arg == "--min-power" && i + 1 < argc) {
                config.min_power = std::stoi(argv[++i]);
            } else if (arg == "--max-power" && i + 1 < argc) {
                config.max_power = std::stoi(argv[++i]);
            } else if (arg == "--target-batch-ms" && i + 1 < argc) {
                config.target_batch_ms = std::stof(argv[++i]);
            } else if (arg == "--max-batch-repeats" && i + 1 < argc) {
                config.max_batch_repeats = std::stoi(argv[++i]);
            } else {
                throw_runtime("Unknown argument: " + arg);
            }
        }

        if (mode == "--self-test") {
            std::cout << run_self_test() << '\n';
            return 0;
        }

        run_benchmark(config);
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << '\n';
        return 1;
    }
}
