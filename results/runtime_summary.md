# Random Rotation Benchmark Summary

The tables below report mean runtime in milliseconds with 95% confidence intervals across repeated trials.
Sub-millisecond paths use batched timing and are divided back down to per-transform runtimes to reduce launch-overhead noise.

## setup_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 460 | 1.143283 | [1.110874, 1.175692] |
| Haar QR | 512 | 8 | 191 | 2.505607 | [2.460400, 2.550815] |
| Haar QR | 1024 | 8 | 95 | 5.650419 | [5.568888, 5.731950] |
| Haar QR | 2048 | 8 | 39 | 13.984635 | [13.832641, 14.136630] |
| Haar QR | 4096 | 6 | 12 | 48.301351 | [46.704894, 49.897808] |
| Haar QR | 8192 | 5 | 3 | 231.895285 | [220.849839, 242.940732] |
| Haar QR | 16384 | 4 | 1 | 1495.467926 | [1178.222900, 1812.712952] |
| Haar QR | 32768 | 3 | 1 | 11648.872070 | [11466.123934, 11831.620207] |
| Reflector Chain | 256 | 12 | 8192 | 0.019224 | [0.018317, 0.020132] |
| Reflector Chain | 512 | 12 | 8192 | 0.021105 | [0.020680, 0.021530] |
| Reflector Chain | 1024 | 12 | 8192 | 0.028650 | [0.027565, 0.029735] |
| Reflector Chain | 2048 | 12 | 6104 | 0.075214 | [0.074676, 0.075752] |
| Reflector Chain | 4096 | 12 | 1796 | 0.260345 | [0.259072, 0.261618] |
| Reflector Chain | 8192 | 12 | 519 | 1.003139 | [0.996384, 1.009894] |
| Reflector Chain | 16384 | 10 | 137 | 3.965821 | [3.932160, 3.999482] |
| Reflector Chain | 32768 | 8 | 35 | 15.979464 | [15.843739, 16.115189] |
| RHT | 256 | 16 | 8192 | 0.006472 | [0.005771, 0.007174] |
| RHT | 512 | 16 | 8192 | 0.006155 | [0.005781, 0.006530] |
| RHT | 1024 | 16 | 8192 | 0.006449 | [0.005803, 0.007096] |
| RHT | 2048 | 16 | 8192 | 0.006240 | [0.005688, 0.006791] |
| RHT | 4096 | 16 | 8192 | 0.005865 | [0.005574, 0.006156] |
| RHT | 8192 | 16 | 8192 | 0.006004 | [0.005583, 0.006426] |
| RHT | 16384 | 16 | 8192 | 0.006112 | [0.005690, 0.006534] |
| RHT | 32768 | 12 | 8192 | 0.007255 | [0.006614, 0.007896] |
| RHT | 65536 | 12 | 8192 | 0.006479 | [0.006141, 0.006817] |
| RHT | 131072 | 12 | 8192 | 0.006492 | [0.005868, 0.007117] |
| RHT | 262144 | 12 | 8192 | 0.006743 | [0.006521, 0.006965] |

## apply_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 8192 | 0.013132 | [0.012415, 0.013850] |
| Haar QR | 512 | 8 | 8192 | 0.012156 | [0.011146, 0.013166] |
| Haar QR | 1024 | 8 | 8192 | 0.010657 | [0.010171, 0.011144] |
| Haar QR | 2048 | 8 | 8192 | 0.027434 | [0.027364, 0.027504] |
| Haar QR | 4096 | 6 | 4933 | 0.101192 | [0.100957, 0.101427] |
| Haar QR | 8192 | 5 | 1120 | 0.396703 | [0.394842, 0.398563] |
| Haar QR | 16384 | 4 | 298 | 1.570001 | [1.562941, 1.577061] |
| Haar QR | 32768 | 3 | 51 | 6.700895 | [6.560945, 6.840846] |
| Reflector Chain | 256 | 12 | 2359 | 0.209611 | [0.209479, 0.209742] |
| Reflector Chain | 512 | 12 | 1078 | 0.477846 | [0.477491, 0.478201] |
| Reflector Chain | 1024 | 12 | 433 | 1.205230 | [1.204000, 1.206460] |
| Reflector Chain | 2048 | 12 | 128 | 4.718023 | [4.714173, 4.721873] |
| Reflector Chain | 4096 | 12 | 34 | 15.576009 | [15.565046, 15.586972] |
| Reflector Chain | 8192 | 12 | 10 | 55.352815 | [55.294925, 55.410704] |
| Reflector Chain | 16384 | 10 | 3 | 221.350070 | [221.152860, 221.547280] |
| Reflector Chain | 32768 | 8 | 1 | 974.758141 | [972.500084, 977.016197] |
| RHT | 256 | 16 | 8192 | 0.037547 | [0.036144, 0.038949] |
| RHT | 512 | 16 | 8192 | 0.036249 | [0.035405, 0.037092] |
| RHT | 1024 | 16 | 8192 | 0.037848 | [0.036949, 0.038746] |
| RHT | 2048 | 16 | 6511 | 0.093023 | [0.089613, 0.096433] |
| RHT | 4096 | 16 | 5026 | 0.099047 | [0.093603, 0.104490] |
| RHT | 8192 | 16 | 5140 | 0.104451 | [0.101974, 0.106927] |
| RHT | 16384 | 16 | 6884 | 0.109914 | [0.106514, 0.113314] |
| RHT | 32768 | 12 | 3256 | 0.133184 | [0.129501, 0.136866] |
| RHT | 65536 | 12 | 3212 | 0.125243 | [0.120607, 0.129879] |
| RHT | 131072 | 12 | 3907 | 0.125677 | [0.122002, 0.129352] |
| RHT | 262144 | 12 | 4036 | 0.147568 | [0.142653, 0.152483] |

## end_to_end_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 451 | 1.183642 | [1.153140, 1.214144] |
| Haar QR | 512 | 8 | 191 | 2.535029 | [2.468491, 2.601568] |
| Haar QR | 1024 | 8 | 88 | 5.624351 | [5.539327, 5.709374] |
| Haar QR | 2048 | 8 | 36 | 14.175658 | [13.985202, 14.366114] |
| Haar QR | 4096 | 6 | 12 | 50.052335 | [49.429494, 50.675175] |
| Haar QR | 8192 | 5 | 3 | 242.877884 | [234.926593, 250.829174] |
| Haar QR | 16384 | 4 | 1 | 1398.997894 | [1367.657108, 1430.338680] |
| Haar QR | 32768 | 3 | 1 | 11656.609375 | [11312.643626, 12000.575125] |
| Reflector Chain | 256 | 12 | 2098 | 0.218042 | [0.217894, 0.218189] |
| Reflector Chain | 512 | 12 | 1033 | 0.489186 | [0.488784, 0.489587] |
| Reflector Chain | 1024 | 12 | 421 | 1.220914 | [1.219310, 1.222518] |
| Reflector Chain | 2048 | 12 | 126 | 4.013801 | [4.010173, 4.017429] |
| Reflector Chain | 4096 | 12 | 33 | 14.991080 | [14.974219, 15.007941] |
| Reflector Chain | 8192 | 12 | 10 | 55.287384 | [55.221363, 55.353404] |
| Reflector Chain | 16384 | 10 | 3 | 223.309102 | [223.220833, 223.397371] |
| Reflector Chain | 32768 | 8 | 1 | 986.780106 | [986.067826, 987.492385] |
| RHT | 256 | 16 | 8192 | 0.041846 | [0.040917, 0.042775] |
| RHT | 512 | 16 | 7181 | 0.040307 | [0.039120, 0.041494] |
| RHT | 1024 | 16 | 8192 | 0.042416 | [0.041132, 0.043699] |
| RHT | 2048 | 16 | 4537 | 0.099055 | [0.095906, 0.102204] |
| RHT | 4096 | 16 | 5195 | 0.101076 | [0.098787, 0.103364] |
| RHT | 8192 | 16 | 4835 | 0.112884 | [0.110650, 0.115118] |
| RHT | 16384 | 16 | 3907 | 0.117132 | [0.114031, 0.120233] |
| RHT | 32768 | 12 | 3376 | 0.140610 | [0.137483, 0.143737] |
| RHT | 65536 | 12 | 2505 | 0.132247 | [0.128631, 0.135862] |
| RHT | 131072 | 12 | 4003 | 0.132904 | [0.130395, 0.135412] |
| RHT | 262144 | 12 | 3766 | 0.158856 | [0.153664, 0.164049] |

## Empirical Scaling Exponents

Adjacent exponents use consecutive powers of two. Tail fit uses the largest three available dimensions for that method/metric.

| Method | Metric | Largest Adjacent Exponent | Tail Fit Exponent |
| --- | --- | ---: | ---: |
| Haar QR | setup_ms | 2.962 | 2.825 |
| Reflector Chain | setup_ms | 2.011 | 1.997 |
| RHT | setup_ms | 0.055 | 0.029 |
| Haar QR | apply_ms | 2.094 | 2.039 |
| Reflector Chain | apply_ms | 2.139 | 2.069 |
| RHT | apply_ms | 0.232 | 0.118 |
| Haar QR | end_to_end_ms | 3.059 | 2.792 |
| Reflector Chain | end_to_end_ms | 2.144 | 2.079 |
| RHT | end_to_end_ms | 0.257 | 0.132 |

## Failures

- Haar QR at d=65536 for apply_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=65536 for end_to_end_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=65536 for setup_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=131072 for apply_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=131072 for end_to_end_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=131072 for setup_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=262144 for apply_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=262144 for end_to_end_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 7.93 GiB
- Haar QR at d=262144 for setup_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=65536 for apply_ms: Skipped: estimated method state 8.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=65536 for end_to_end_ms: Skipped: estimated method state 8.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=65536 for setup_ms: Skipped: estimated method state 8.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=131072 for apply_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=131072 for end_to_end_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=131072 for setup_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=262144 for apply_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=262144 for end_to_end_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 7.93 GiB
- Reflector Chain at d=262144 for setup_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 7.93 GiB

## Figures

- `results\figures\setup_ms.png`
- `results\figures\apply_ms.png`
- `results\figures\end_to_end_ms.png`
