function [PI] = decryption(CI, In_Key)
tic;

x1 = In_Key(1);
y1 = In_Key(2);
z1 = In_Key(3);
u1 = In_Key(4);
v1 = In_Key(5);
w1 = In_Key(6);

[M, N, Z] = size(CI);

% --- 设置 HRNM 混沌系统参数 ---
% phi = 1;
% alpha = 0.5;              % 控制参数 alpha
% beta = 1;               % 控制参数 beta
% alpha1 = -0.1;            % 控制参数 alpha1
% coupling_strength = 0.2;  % 维度间的耦合强度 k
% beta1 = -0.045;           % 控制参数 beta1
% epsilon = 0.02;           % 微小常数项
% sigma = -1.605;           % 系统参数 sigma

% --- 设定 Memristive H-R neuron model With Threshold Policy Control 参数 ---
a = 1; b = 3; c = 1; d = 2; I = 1; k = 2.5; MT = 1;

% 混沌序列生成

% --- 混沌序列生成 (数值积分) ---
% 瞬态消除点数：避开混沌系统开始阶段的不稳定轨迹
transient_points = 1000;
% 计算所需序列总长度：确保足够覆盖图像所有像素分量
total_points = M*N*Z + Z + transient_points;

% 时间积分设置
start_time = 0;
time_step = 0.1;       % 步长越小，解的精度越高
end_time = start_time + time_step * (total_points - 1);
time_vector = start_time:time_step:end_time; % 构建时间轴

% 使用 ODE45 (四五阶龙格-库塔法) 求解混沌微分方程
% [~, ode_solution1] = ode45(@(t, Y) hrnm(t, Y, ...
%   alpha, beta, alpha1, beta1, coupling_strength, sigma, phi, epsilon), ...
%   time_vector, [x1, y1, z1]);

[~, ode_solution1] = ode45(@(t, Y) hrnm(t, Y, ...
  a, b, c, d, I, k, MT), ...
  time_vector, [x1, y1, z1]);

% [~, ode_solution2] = ode45(@(t, Y) hrnm(t, Y, ...
%   alpha, beta, alpha1, beta1, coupling_strength, sigma, phi, epsilon), ...
%   time_vector, [u1, v1, w1]);

[~, ode_solution2] = ode45(@(t, Y) hrnm(t, Y, ...
  a, b, c, d, I, k, MT), ...
  time_vector, [u1, v1, w1]);

% 逆扩散
length_for_josephus_vector = M * N * Z + 1;
chaotic_sequence_for_josephus_vector = ode_solution2(total_points - length_for_josephus_vector + 1:end, 1);

start = mod(floor(chaotic_sequence_for_josephus_vector(1)*10^15), length_for_josephus_vector) + 1;
space = mod(floor(chaotic_sequence_for_josephus_vector(2:end).*10^15), length_for_josephus_vector) + 1;

length_for_loop_maintaince = M*N*Z;
chaotic_sequence_for_loop_maintaince =mod(floor(ode_solution2(total_points - length_for_loop_maintaince + 1:end, 2).*10^15), 2);

josephus_vector = generate_dynamic_josephus_vector(M, N, Z, start, space, chaotic_sequence_for_loop_maintaince);
josephus_diffusion_matrix = reshape(josephus_vector, [M, N, Z]);

length_for_diffusion_matrix = M * N * Z;
chaotic_diffusion_matrix = uint8(reshape(mod(ode_solution2(total_points - length_for_diffusion_matrix + 1:end, 3).*10^15, 256), [M, N, Z]));

de_diffused_image = de_josephus_diffusion(CI, josephus_diffusion_matrix, chaotic_diffusion_matrix, M, N, Z);

% 逆置乱
length_for_josephus_matrix = M*N*Z+Z;
chaotic_sequence_for_josephus_matrix = ode_solution1(total_points - length_for_josephus_matrix + 1:end, 1);
start = mod(floor(chaotic_sequence_for_josephus_matrix(1:3).*10^15), M * N) + 1;
space = mod(floor(chaotic_sequence_for_josephus_matrix(4:end).*10^15), M * N) + 1;
space = reshape(space, [Z, M * N]);

length_for_loop_maintaince = M*N*Z;
chaotic_matrix_for_loop_maintaince =reshape(mod(floor(ode_solution1(total_points - length_for_loop_maintaince + 1:end, 2).*10^15), 2),[Z,M*N]);

% 生成动态约瑟夫矩阵
dynamic_josephus_matrix = generate_dynamic_josephus_matrix(M, N, Z, start, space, chaotic_matrix_for_loop_maintaince);

%  生成跨层矩阵
length_for_cross_layer_matrix = M*N*Z;
chaotic_sequence_for_cross_layer_matrix = ode_solution1(total_points - length_for_cross_layer_matrix + 1:end, 3);
cross_layer_matrix = uint8(generate_cross_layer_matrix(chaotic_sequence_for_cross_layer_matrix, M, N, Z));

de_permuted_image = de_cross_layer_scrambling(de_diffused_image, dynamic_josephus_matrix, cross_layer_matrix);

PI = uint8(de_permuted_image);

t = toc;
fprintf('解密程序运行耗时：%.4f 秒\n', t);
fprintf("----------------------\n");
end
