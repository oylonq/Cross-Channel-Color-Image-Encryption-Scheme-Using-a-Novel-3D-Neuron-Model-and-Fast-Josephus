function [CI] = encryption_ablation(PI, In_Key, mode)
%ENCRYPTION_ABLATION 加密方案的消融变体
%   CI = encryption_ablation(PI, In_Key, mode)
%
%   输入:
%       PI       - 明文彩色图像 (M x N x 3, uint8)
%       In_Key   - 6 维初始密钥 [x1,y1,z1,u1,v1,w1]
%       mode     - 消融模式:
%                  'full'            - 完整方案
%                  'no_cmja'         - 用简单混沌排序置换代替 CMJA
%                  'no_clmm'         - 去掉跨层映射矩阵 (CLMM)
%                  'no_dynamic_diff' - 用固定顺序 XOR 扩散代替约瑟夫动态扩散
%
%   输出:
%       CI       - 密文图像 (uint8)

    if nargin < 3
        mode = 'full';
    end

    x1 = In_Key(1);
    y1 = In_Key(2);
    z1 = In_Key(3);
    u1 = In_Key(4);
    v1 = In_Key(5);
    w1 = In_Key(6);

    [M, N, Z] = size(PI);

    % --- MHR 混沌系统参数 ---
    a = 1; b = 3; c = 1; d = 2; I = 1; k = 2.5; MT = 1;

    % --- 混沌序列生成 ---
    transient_points = 1000;
    total_points = M * N * Z + Z + transient_points;

    start_time = 0;
    time_step = 0.1;
    end_time = start_time + time_step * (total_points - 1);
    time_vector = start_time:time_step:end_time;

    [~, ode_solution1] = ode45(@(t, Y) hrnm(t, Y, a, b, c, d, I, k, MT), ...
                               time_vector, [x1, y1, z1]);
    [~, ode_solution2] = ode45(@(t, Y) hrnm(t, Y, a, b, c, d, I, k, MT), ...
                               time_vector, [u1, v1, w1]);

    % ========== 置乱阶段 ==========
    length_for_josephus_matrix = M * N * Z + Z;
    chaotic_sequence_for_josephus_matrix = ode_solution1(total_points - length_for_josephus_matrix + 1:end, 1);

    start = mod(floor(chaotic_sequence_for_josephus_matrix(1:3) .* 10^15), M * N) + 1;
    space = mod(floor(chaotic_sequence_for_josephus_matrix(4:end) .* 10^15), M * N) + 1;
    space = reshape(space, [Z, M * N]);

    length_for_loop_maintaince = M * N * Z;
    chaotic_matrix_for_loop_maintaince = reshape(mod(floor(ode_solution1(total_points - length_for_loop_maintaince + 1:end, 2) .* 10^15), 2), [Z, M * N]);

    if strcmpi(mode, 'no_cmja')
        % 去掉 CMJA 空间置乱：使用恒等映射
        dynamic_josephus_matrix = identity_josephus_matrix(M, N, Z);
    else
        dynamic_josephus_matrix = generate_dynamic_josephus_matrix(M, N, Z, start, space, chaotic_matrix_for_loop_maintaince);
    end

    length_for_cross_layer_matrix = M * N * Z;
    chaotic_sequence_for_cross_layer_matrix = ode_solution1(total_points - length_for_cross_layer_matrix + 1:end, 3);

    if strcmpi(mode, 'no_clmm')
        % 去掉跨层映射，每个通道独立置乱
        cross_layer_matrix = repmat(reshape(1:Z, 1, 1, Z), M, N, 1);
    else
        cross_layer_matrix = uint8(generate_cross_layer_matrix(chaotic_sequence_for_cross_layer_matrix, M, N, Z));
    end

    permuted_image = cross_layer_scrambling(PI, dynamic_josephus_matrix, cross_layer_matrix);

    % ========== 扩散阶段 ==========
    length_for_josephus_vector = M * N * Z + 1;
    chaotic_sequence_for_josephus_vector = ode_solution2(total_points - length_for_josephus_vector + 1:end, 1);

    start = mod(floor(chaotic_sequence_for_josephus_vector(1) * 10^15), length_for_josephus_vector) + 1;
    space = mod(floor(chaotic_sequence_for_josephus_vector(2:end) .* 10^15), length_for_josephus_vector) + 1;

    length_for_loop_maintaince = M * N * Z;
    chaotic_sequence_for_loop_maintaince = mod(floor(ode_solution2(total_points - length_for_loop_maintaince + 1:end, 2) .* 10^15), 2);

    length_for_diffusion_matrix = M * N * Z;
    chaotic_diffusion_matrix = uint8(reshape(mod(ode_solution2(total_points - length_for_diffusion_matrix + 1:end, 3) .* 10^15, 256), [M, N, Z]));

    if strcmpi(mode, 'no_diffusion')
        % 去掉扩散：仅保留置乱结果
        CI = uint8(permuted_image);
        return;
    elseif strcmpi(mode, 'no_dynamic_diff')
        % 固定顺序 XOR 扩散（保持密钥矩阵不变）
        diffused_image = fixed_order_diffusion(uint8(permuted_image), chaotic_diffusion_matrix, M, N, Z);
    else
        josephus_vector = generate_dynamic_josephus_vector(M, N, Z, start, space, chaotic_sequence_for_loop_maintaince);
        josephus_diffusion_matrix = reshape(josephus_vector, [M, N, Z]);
        diffused_image = josephus_diffusion(uint8(permuted_image), josephus_diffusion_matrix, chaotic_diffusion_matrix, M, N, Z);
    end

    CI = uint8(diffused_image);
end

%% ==================== 局部辅助函数 ====================

function [PM] = identity_josephus_matrix(M, N, Z)
% 恒等置乱矩阵：每个输出位置 (i,j,k) 直接从输入的同名空间位置取像素
    PM = zeros(M, N, Z);
    base = reshape(1:M*N, [M, N]);
    for k = 1:Z
        PM(:, :, k) = base;
    end
end

function [DI] = fixed_order_diffusion(PI, K, M, N, Z)
% 按 (k,i,j) 的固定光栅顺序进行 XOR 扩散
    DI = zeros(M, N, Z, 'uint8');
    pre = uint8(0);
    for k = 1:Z
        for i = 1:M
            for j = 1:N
                px = bitxor(bitxor(PI(i, j, k), pre), K(i, j, k));
                DI(i, j, k) = px;
                pre = px;
            end
        end
    end
end
