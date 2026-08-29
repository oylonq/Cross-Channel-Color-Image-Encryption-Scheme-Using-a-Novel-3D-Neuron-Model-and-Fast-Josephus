clc;clear;

% 获取加密图像
plain_img = imread("../Images/misc/house.tiff");
plain_img = imresize(plain_img, [256,256]);
[M, N, Z] = size(plain_img);


tic;
% 设置外部密钥
ext_sec_key = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];

% 设置放缩参数
scale_factor = 0.1;

% 生成内部密钥
in_sec_key = gen_in_sec_key(plain_img, ext_sec_key, scale_factor);
t = toc;
fprintf('内部密钥生成运行耗时：%.4f 秒\n', t);


% 置乱阶段


tic;
% --- 设置 HRNM 混沌系统参数 ---
phi = 1;
alpha = 0.5;              % 控制参数 alpha
beta = 1;               % 控制参数 beta
alpha1 = -0.1;            % 控制参数 alpha1
coupling_strength = 0.2;  % 维度间的耦合强度 k
beta1 = -0.045;           % 控制参数 beta1
epsilon = 0.02;           % 微小常数项
sigma = -1.605;           % 系统参数 sigma

% 设置混沌系统初始值
x1 = in_sec_key(1);
y1 = in_sec_key(2);
z1 = in_sec_key(3);

% 生成置乱过程所需的混沌序列
scramble_chaos_seq = gen_chaos_seq(M, N, Z, phi, alpha, beta, alpha1, coupling_strength, beta1, epsilon, sigma, x1, y1, z1);
t = toc;
fprintf('生成生成置乱过程所需混沌序列运行耗时：%.4f 秒\n', t);


% 混沌序列预处理

% 生成约瑟夫序列

% 执行置乱


% 扩散阶段
% 生成混沌序列
% --- 设置 HRNM 混沌系统参数 ---
phi = 1;
alpha = 0.5;              % 控制参数 alpha
beta = 1;               % 控制参数 beta
alpha1 = -0.1;            % 控制参数 alpha1
coupling_strength = 0.2;  % 维度间的耦合强度 k
beta1 = -0.045;           % 控制参数 beta1
epsilon = 0.02;           % 微小常数项
sigma = -1.605;           % 系统参数 sigma

% 设置初始值
u1 = in_sec_key(4);
v1 = in_sec_key(5);
w1 = in_sec_key(6);
% 混沌序列预处理
% 生成约瑟夫序列
% 执行扩散

% 生成内部密钥
function [img_digest] = gen_img_digest(img, hash_method)
% 使用 Java Bridge 计算图像文件的哈希值

img = reshape(img, 1, []);

% --- 使用 Java MessageDigest 计算哈希值 ---
try
  % 获取哈希实例
  %message_digest = java.security.MessageDigest.getInstance('SHA-256');
  message_digest = java.security.MessageDigest.getInstance(hash_method);

  % 更新哈希摘要 (将 MATLAB uint8 数组传递给 Java)
  message_digest.update(img);

  % 计算最终哈希值 (Java byte array)
  digest_bytes = message_digest.digest();

  % 转换为 MATLAB uint8 数组
  img_digest = typecast(digest_bytes, 'uint8');

catch Error
  error('哈希计算失败: %s', Error.message);
end

end

function [in_sec_key] = gen_in_sec_key(img, ext_sec_key, scale_factor)
% 密钥生成
image_sha512_digest = gen_img_digest(img, "SHA-512");
binary_32bit_strings = reshape(dec2bin(image_sha512_digest), [], 32);
decimal_32bit_values = bin2dec(binary_32bit_strings);

perturbation_vector = zeros(1, 6);
decimal_blocks = length(decimal_32bit_values); % 原始数据块的数量

for i = 1:6
  % 逻辑：每个 perturbation_vector(i) 由 idx1, idx2, idx3 三个位置的值异或而成
  idx1 = i;
  idx2 = mod(i + 6 - 1, decimal_blocks) + 1; % 相当于原来的 i+6
  idx3 = mod(i + 12 - 1, decimal_blocks) + 1; % 相当于原来的 i+12

  % 执行连续异或
  perturbation_vector(i) = bitxor(bitxor(decimal_32bit_values(idx1), ...
    decimal_32bit_values(idx2)), ...
    decimal_32bit_values(idx3));
end

perturbation_vector = mod(perturbation_vector / 2^32, 1);

% --- 生成最终关联明文的混沌初值 (Perturbed Keys) ---
% 将外部密钥与基于图像生成的扰动量融合，实现“一图一密”
in_sec_key = mod(ext_sec_key + scale_factor * perturbation_vector, 1);
% x1 = mod(x0 + scale_factor * perturbation_vector(1), 1);
% y1 = mod(y0 + scale_factor * perturbation_vector(2), 1);
% z1 = mod(z0 + scale_factor * perturbation_vector(3), 1);
% u1 = mod(u0 + scale_factor * perturbation_vector(4), 1);
% v1 = mod(v0 + scale_factor * perturbation_vector(5), 1);
% w1 = mod(w0 + scale_factor * perturbation_vector(6), 1);

end

% 生成混沌序列
function [chaos_seq] = gen_chaos_seq(M, N, Z, phi, alpha, beta, alpha1, coupling_strength, beta1, epsilon, sigma, x1, y1, z1)
% --- 设置 HRNM 混沌系统参数 ---
% phi = 1;
% alpha = 0.5;              % 控制参数 alpha
% beta = 1;               % 控制参数 beta
% alpha1 = -0.1;            % 控制参数 alpha1
% coupling_strength = 0.2;  % 维度间的耦合强度 k
% beta1 = -0.045;           % 控制参数 beta1
% epsilon = 0.02;           % 微小常数项
% sigma = -1.605;           % 系统参数 sigma

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
[~, chaos_seq] = ode45(@(t, Y) hrnm(t, Y, ...
  alpha, beta, alpha1, beta1, coupling_strength, sigma, phi, epsilon), ...
  time_vector, [x1, y1, z1]);

end


