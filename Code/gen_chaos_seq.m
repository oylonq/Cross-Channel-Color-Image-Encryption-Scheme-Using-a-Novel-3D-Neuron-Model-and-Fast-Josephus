function [chaos_seq] = gen_chaos_seq(phi, alpha, beta, alpha1, coupling_strength, beta1, epsilon, sigma, x1, y1, z1)
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
