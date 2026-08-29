clc; clear; close all;

%% 1. 读取需要加密的图片
PI0 = imread("../Images/misc/4.2.03.tiff");
PI1 = imread("../Images/misc/4.2.06.tiff");
PI2 = imread("../Images/misc/4.2.07.tiff");
PI3 = imread("../Images/misc/house.tiff");

PI0 = imresize(PI0, [256, 256]);
PI1 = imresize(PI1, [256, 256]);
PI2 = imresize(PI2, [512, 512]);
PI3 = imresize(PI3, [256, 256]);
PI = {PI0, PI1, PI2, PI3};

names = {"Mandrill", "Sailboat on lake", "Peppers", "House"};

%% 2. 加密过程
Ex_Key0 = [1, -3, 0.3, 1.5, -2.5, 0.4];
scale_factor = 0.2;

[In_Key0] = generate_key(PI0, Ex_Key0, scale_factor);

% 获取加密图像
[CI0] = encryption(PI0, In_Key0);
[CI1] = encryption(PI1, In_Key0);
[CI2] = encryption(PI2, In_Key0);
[CI3] = encryption(PI3, In_Key0);

CI = {CI0, CI1, CI2, CI3};

compare_rgb_entropy(PI, CI, names);

function compare_rgb_entropy(PI_cell, CI_cell, name_cell)
    % 批量比较明文和密文的 RGB 三通道信息熵
    n_images = length(name_cell);

    fprintf('\n======================== Information Entropy Results ========================\n');
    fprintf('%-18s | %-7s | %-12s | %-12s | %-8s\n', 'Image Name', 'Channel', 'Plaintext', 'Ciphertext', 'Ideal');
    fprintf('-----------------------------------------------------------------------------\n');

    for i = 1:n_images
        % 计算明文三通道熵
        [pR, pG, pB] = calculate_rgb_entropy(PI_cell{i});
        % 计算密文三通道熵
        [cR, cG, cB] = calculate_rgb_entropy(CI_cell{i});

        % 打印 R 通道
        fprintf('%-18s | %-7s | %-12.4f | %-12.4f | 8.0000\n', name_cell{i}, 'R', pR, cR);
        % 打印 G 通道
        fprintf('%-18s | %-7s | %-12.4f | %-12.4f | 8.0000\n', '', 'G', pG, cG);
        % 打印 B 通道
        fprintf('%-18s | %-7s | %-12.4f | %-12.4f | 8.0000\n', '', 'B', pB, cB);

        fprintf('-----------------------------------------------------------------------------\n');
    end
end

function [entropy_R, entropy_G, entropy_B] = calculate_rgb_entropy(image)
    
    if size(image, 3) == 1
        image = repmat(image, [1, 1, 3]);
    end

    R = image(:, :, 1);
    G = image(:, :, 2);
    B = image(:, :, 3);

    entropy_R = calculate_entropy(R);
    entropy_G = calculate_entropy(G);
    entropy_B = calculate_entropy(B);
end

function entropy_value = calculate_entropy(channel_data)
    % 基础信息熵计算核心
    channel_data = double(channel_data);
    [counts, ~] = imhist(uint8(channel_data), 256);

    total_pixels = sum(counts);
    probabilities = counts / total_pixels;

    % 去除概率为0的点（避免log2(0)等于-Inf）
    probabilities(probabilities == 0) = [];

    % 计算信息熵公式: H = -sum(p * log2(p))
    entropy_value = -sum(probabilities .* log2(probabilities));
end