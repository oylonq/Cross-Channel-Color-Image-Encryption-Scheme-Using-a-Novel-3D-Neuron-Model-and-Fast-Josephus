clear; clc; close all;

% 1. 图像读取与预处理
try
    PI0 = imread("../Images/misc/4.2.03.tiff"); 
    PI0 = imresize(PI0, [256, 256]);
catch
    PI0 = imresize(imread('mandril.png'), [256, 256]);
end

% 2. 密钥生成与加密
Ex_Key = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
scale_factor = 0.1;
In_Key = generate_key(PI0, Ex_Key, scale_factor);
CI0 = encryption(PI0, In_Key);

noise_densities = [0.1, 0.2, 0.3, 0.4]; 
num_tests = length(noise_densities);


figure('Name', 'Noise Robustness Analysis', 'Color', 'w', 'Position', [100, 100, 1000, 500]);
tlo = tiledlayout(2, num_tests, 'Padding', 'tight', 'TileSpacing', 'compact');

% 5. 循环测试
for i = 1:num_tests
    density = noise_densities(i);
    
    % --- 添加椒盐噪声 ---
    noisy_CI = imnoise(CI0, 'salt & pepper', density);
    
    % --- 执行解密 ---
    decrypted_img = decryption(noisy_CI, In_Key);
    
    % --- 计算 MSE 和 PSNR (用于控制台记录) ---
    orig_double = double(PI0);
    decr_double = double(decrypted_img);
    
    mse_val = mean((orig_double(:) - decr_double(:)).^2);
    psnr_val = 10 * log10(255^2 / mse_val);
    
   
    fprintf('密度: %.1f | MSE: %.4f | PSNR: %.2f dB\n', density, mse_val, psnr_val);
    
    
    nexttile(i);
    imshow(noisy_CI);
    
    
    nexttile(i + num_tests);
    imshow(decrypted_img);
end
