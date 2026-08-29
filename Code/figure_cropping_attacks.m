clear; clc; close all;

try
    
    PI0 = imread("../Images/misc/4.2.03.tiff"); 
    PI0 = imresize(PI0, [256, 256]);
catch
    warning('未找到指定路径图片，使用内置 Mandrill 图像测试');
    PI0 = imresize(imread('mandril.png'), [256, 256]);
end
[m, n, ~] = size(PI0);


Ex_Key = [1, -1, 0.1, 1.5, -1.5, 0.2];
scale_factor = 0.2;
In_Key = generate_key(PI0, Ex_Key, scale_factor);
CI0 = encryption(PI0, In_Key);

radii_ratios = [0.1, 0.2, 0.3, 0.4]; 
num_crop = length(radii_ratios);

figure('Name', 'Circular Cropping Attack', 'Color', 'w', 'Position', [100, 100, 1000, 500]);
tlo1 = tiledlayout(2, num_crop, 'Padding', 'tight', 'TileSpacing', 'compact');

fprintf('\n%s\n', repmat('=', 1, 55));
fprintf('Part 1: Circular Cropping Attack Results\n');
fprintf('%-15s | %-15s | %-15s\n', 'Radius Ratio', 'MSE', 'PSNR (dB)');
fprintf('%s\n', repmat('-', 1, 55));

code_idx = 0; % 用于生成 (a), (b), (c)...
labels = cellstr(char(97:97+15)'); % 预生成 a-p 的标签

for i = 1:num_crop
    r = radii_ratios(i);
    attacked_CI = CI0;
    [X, Y] = meshgrid(1:n, 1:m);
    mask = ((X - n/2).^2 + (Y - m/2).^2) < (min(m,n)*r)^2;
    attacked_CI(repmat(mask, [1, 1, 3])) = 0; 
    
    
    [~, de_img] = evalc('decryption(attacked_CI, In_Key)');
    
    % 计算指标
    mse_val = mean((double(PI0(:)) - double(de_img(:))).^2);
    psnr_val = 10 * log10(255^2 / mse_val);
    fprintf('%-15.1f | %-15.4f | %-15.2f\n', r, mse_val, psnr_val);
    
    % 绘图
    nexttile(i); imshow(attacked_CI);
    draw_label(labels{code_idx + i});
    nexttile(i + num_crop); imshow(de_img);
    draw_label(labels{code_idx + 4 + i});
end
fprintf('%s\n', repmat('=', 1, 55));
% title(tlo1, 'Circular Cropping Attack Analysis');

noise_densities = [0.1, 0.2, 0.3, 0.4]; 
num_noise = length(noise_densities);

figure('Name', 'Salt & Pepper Noise Attack', 'Color', 'w', 'Position', [150, 150, 1000, 500]);
tlo2 = tiledlayout(2, num_noise, 'Padding', 'tight', 'TileSpacing', 'compact');

fprintf('\n%s\n', repmat('=', 1, 55));
fprintf('Part 2: Salt & Pepper Noise Attack Results\n');
fprintf('%-15s | %-15s | %-15s\n', 'Noise Density', 'MSE', 'PSNR (dB)');
fprintf('%s\n', repmat('-', 1, 55));

for i = 1:num_noise
    d = noise_densities(i);
    noisy_CI = imnoise(CI0, 'salt & pepper', d);
    
    % 使用 evalc 屏蔽输出
    [~, de_img] = evalc('decryption(noisy_CI, In_Key)');
    
    % 计算指标
    mse_val = mean((double(PI0(:)) - double(de_img(:))).^2);
    psnr_val = 10 * log10(255^2 / mse_val);
    fprintf('%-15.1f | %-15.4f | %-15.2f\n', d, mse_val, psnr_val);
    
    % 绘图
    nexttile(i); imshow(noisy_CI);
    draw_label(labels{code_idx + i});
    nexttile(i + num_noise); imshow(de_img);
    draw_label(labels{code_idx + 4 + i});
end
fprintf('%s\n', repmat('=', 1, 55));

function draw_label(txt)
    xlabel(['(', txt, ')'], 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
end
