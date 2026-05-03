# Random Rotation Benchmark Summary

The tables below report mean runtime in milliseconds with 95% confidence intervals across repeated trials.
Sub-millisecond paths use batched timing and are divided back down to per-transform runtimes to reduce launch-overhead noise.

## setup_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 444 | 1.174038 | [1.131758, 1.216318] |
| Haar QR | 512 | 8 | 207 | 2.561518 | [2.503561, 2.619474] |
| Haar QR | 1024 | 8 | 85 | 5.757911 | [5.670536, 5.845285] |
| Haar QR | 2048 | 8 | 37 | 13.947585 | [13.756189, 14.138981] |
| Haar QR | 4096 | 6 | 12 | 45.937305 | [44.495469, 47.379142] |
| Haar QR | 8192 | 5 | 3 | 204.621967 | [197.643202, 211.600731] |
| Haar QR | 16384 | 4 | 1 | 1168.278748 | [1113.286770, 1223.270725] |
| Haar QR | 32768 | 3 | 1 | 9431.692708 | [8809.221944, 10054.163473] |
| Reflector Chain | 256 | 12 | 8192 | 0.019516 | [0.018680, 0.020352] |
| Reflector Chain | 512 | 12 | 8192 | 0.022275 | [0.021451, 0.023099] |
| Reflector Chain | 1024 | 12 | 8192 | 0.028695 | [0.027722, 0.029668] |
| Reflector Chain | 2048 | 12 | 6261 | 0.073831 | [0.073327, 0.074335] |
| Reflector Chain | 4096 | 12 | 1839 | 0.252362 | [0.249009, 0.255715] |
| Reflector Chain | 8192 | 12 | 527 | 0.960567 | [0.951380, 0.969754] |
| Reflector Chain | 16384 | 10 | 138 | 3.766425 | [3.732815, 3.800036] |
| Reflector Chain | 32768 | 8 | 33 | 15.939532 | [15.595329, 16.283736] |
| Reflector Chain | 65536 | 8 | 8 | 66.054932 | [62.990087, 69.119776] |
| RHT | 256 | 16 | 8192 | 0.006681 | [0.006102, 0.007259] |
| RHT | 512 | 16 | 8192 | 0.006500 | [0.005991, 0.007010] |
| RHT | 1024 | 16 | 8192 | 0.006482 | [0.005884, 0.007079] |
| RHT | 2048 | 16 | 8192 | 0.006645 | [0.006099, 0.007190] |
| RHT | 4096 | 16 | 8192 | 0.006409 | [0.005790, 0.007027] |
| RHT | 8192 | 16 | 8092 | 0.006623 | [0.006008, 0.007238] |
| RHT | 16384 | 16 | 8192 | 0.005954 | [0.005616, 0.006291] |
| RHT | 32768 | 12 | 8192 | 0.006105 | [0.005435, 0.006775] |
| RHT | 65536 | 12 | 8192 | 0.006387 | [0.005863, 0.006911] |
| RHT | 131072 | 12 | 8192 | 0.005908 | [0.005651, 0.006164] |
| RHT | 262144 | 12 | 8192 | 0.007246 | [0.006869, 0.007623] |

## apply_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 8192 | 0.011807 | [0.010988, 0.012625] |
| Haar QR | 512 | 8 | 8192 | 0.012459 | [0.011081, 0.013838] |
| Haar QR | 1024 | 8 | 8192 | 0.012462 | [0.010296, 0.014628] |
| Haar QR | 2048 | 8 | 8192 | 0.027324 | [0.027104, 0.027543] |
| Haar QR | 4096 | 6 | 4983 | 0.101057 | [0.099887, 0.102228] |
| Haar QR | 8192 | 5 | 1282 | 0.396879 | [0.389327, 0.404432] |
| Haar QR | 16384 | 4 | 328 | 1.572464 | [1.539129, 1.605799] |
| Haar QR | 32768 | 3 | 67 | 6.451185 | [6.361146, 6.541224] |
| Reflector Chain | 256 | 12 | 2454 | 0.209343 | [0.207899, 0.210787] |
| Reflector Chain | 512 | 12 | 1090 | 0.474791 | [0.469186, 0.480395] |
| Reflector Chain | 1024 | 12 | 422 | 1.206792 | [1.197629, 1.215955] |
| Reflector Chain | 2048 | 12 | 133 | 4.718427 | [4.701062, 4.735793] |
| Reflector Chain | 4096 | 12 | 34 | 15.560675 | [15.482767, 15.638583] |
| Reflector Chain | 8192 | 12 | 10 | 55.431273 | [55.190421, 55.672125] |
| Reflector Chain | 16384 | 10 | 3 | 221.315755 | [219.706887, 222.924622] |
| Reflector Chain | 32768 | 8 | 1 | 976.837120 | [967.756887, 985.917353] |
| Reflector Chain | 65536 | 8 | 1 | 3938.967529 | [3919.507842, 3958.427217] |
| RHT | 256 | 16 | 6029 | 0.037170 | [0.036034, 0.038307] |
| RHT | 512 | 16 | 7751 | 0.036903 | [0.036034, 0.037772] |
| RHT | 1024 | 16 | 8192 | 0.036790 | [0.035235, 0.038345] |
| RHT | 2048 | 16 | 7751 | 0.093769 | [0.090295, 0.097243] |
| RHT | 4096 | 16 | 4034 | 0.100413 | [0.094274, 0.106551] |
| RHT | 8192 | 16 | 5426 | 0.100142 | [0.097288, 0.102995] |
| RHT | 16384 | 16 | 5185 | 0.110558 | [0.107288, 0.113828] |
| RHT | 32768 | 12 | 4174 | 0.114948 | [0.110929, 0.118968] |
| RHT | 65536 | 12 | 4799 | 0.120725 | [0.117756, 0.123694] |
| RHT | 131072 | 12 | 4210 | 0.122900 | [0.117844, 0.127956] |
| RHT | 262144 | 12 | 4607 | 0.146034 | [0.142116, 0.149952] |

## end_to_end_ms

| Method | Dimension | Trials | Batch Repeats | Mean (ms) | 95% CI (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haar QR | 256 | 8 | 441 | 1.179569 | [1.144002, 1.215137] |
| Haar QR | 512 | 8 | 218 | 2.557899 | [2.498042, 2.617756] |
| Haar QR | 1024 | 8 | 79 | 5.815768 | [5.694138, 5.937398] |
| Haar QR | 2048 | 8 | 37 | 14.183239 | [13.878239, 14.488238] |
| Haar QR | 4096 | 6 | 11 | 46.506120 | [45.188347, 47.823894] |
| Haar QR | 8192 | 5 | 3 | 207.904382 | [199.671478, 216.137286] |
| Haar QR | 16384 | 4 | 1 | 1149.960877 | [1113.758826, 1186.162927] |
| Haar QR | 32768 | 3 | 1 | 9623.604167 | [9176.235253, 10070.973080] |
| Reflector Chain | 256 | 12 | 2274 | 0.217692 | [0.216843, 0.218540] |
| Reflector Chain | 512 | 12 | 597 | 0.483883 | [0.481367, 0.486400] |
| Reflector Chain | 1024 | 12 | 421 | 1.214751 | [1.207960, 1.221543] |
| Reflector Chain | 2048 | 12 | 119 | 4.035233 | [3.990313, 4.080154] |
| Reflector Chain | 4096 | 12 | 34 | 15.061602 | [14.993170, 15.130033] |
| Reflector Chain | 8192 | 12 | 10 | 55.789634 | [55.246761, 56.332507] |
| Reflector Chain | 16384 | 10 | 3 | 224.618054 | [223.238261, 225.997847] |
| Reflector Chain | 32768 | 8 | 1 | 989.396973 | [982.821923, 995.972023] |
| Reflector Chain | 65536 | 8 | 1 | 4017.073395 | [3974.916227, 4059.230563] |
| RHT | 256 | 16 | 7876 | 0.044729 | [0.043157, 0.046302] |
| RHT | 512 | 16 | 8192 | 0.043970 | [0.042326, 0.045614] |
| RHT | 1024 | 16 | 4036 | 0.044535 | [0.042369, 0.046700] |
| RHT | 2048 | 16 | 5441 | 0.100604 | [0.095993, 0.105216] |
| RHT | 4096 | 16 | 3768 | 0.105366 | [0.100980, 0.109753] |
| RHT | 8192 | 16 | 3491 | 0.106626 | [0.102811, 0.110442] |
| RHT | 16384 | 16 | 4622 | 0.115315 | [0.111906, 0.118724] |
| RHT | 32768 | 12 | 4104 | 0.121716 | [0.117185, 0.126248] |
| RHT | 65536 | 12 | 4078 | 0.127331 | [0.122703, 0.131959] |
| RHT | 131072 | 12 | 3764 | 0.127814 | [0.123491, 0.132137] |
| RHT | 262144 | 12 | 4284 | 0.156387 | [0.151654, 0.161121] |

## Empirical Scaling Exponents

Adjacent exponents use consecutive powers of two. Tail fit uses the largest three available dimensions for that method/metric.

| Method | Metric | Largest Adjacent Exponent | Tail Fit Exponent |
| --- | --- | ---: | ---: |
| Haar QR | setup_ms | 3.013 | 2.763 |
| Reflector Chain | setup_ms | 2.051 | 2.066 |
| RHT | setup_ms | 0.295 | 0.091 |
| Haar QR | apply_ms | 2.037 | 2.011 |
| Reflector Chain | apply_ms | 2.012 | 2.077 |
| RHT | apply_ms | 0.249 | 0.137 |
| Haar QR | end_to_end_ms | 3.065 | 2.766 |
| Reflector Chain | end_to_end_ms | 2.022 | 2.080 |
| RHT | end_to_end_ms | 0.291 | 0.148 |

## Failures

- Haar QR at d=65536 for apply_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=65536 for end_to_end_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=65536 for setup_ms: Skipped: estimated method state 16.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=131072 for apply_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=131072 for end_to_end_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=131072 for setup_ms: Skipped: estimated method state 64.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=262144 for apply_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=262144 for end_to_end_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 9.00 GiB
- Haar QR at d=262144 for setup_ms: Skipped: estimated method state 256.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=131072 for apply_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=131072 for end_to_end_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=131072 for setup_ms: Skipped: estimated method state 32.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=262144 for apply_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=262144 for end_to_end_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 9.00 GiB
- Reflector Chain at d=262144 for setup_ms: Skipped: estimated method state 128.00 GiB exceeds available benchmark limit 9.00 GiB

## Figures

- `results\figures\setup_ms.png`
- `results\figures\apply_ms.png`
- `results\figures\end_to_end_ms.png`
