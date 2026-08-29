clc; clear; close all;

img_paths = {"../Images/misc/4.2.03.tiff", "../Images/misc/4.2.06.tiff", ...
               "../Images/misc/4.2.07.tiff", "../Images/misc/house.tiff"};

Ex_Key = [1, -3, 0.3, 1.5, -2.5, 0.4];
scale_factor = 0.1;
CIPHER_IMAGES = cell(1, 4);

IMG_NAMES = {'Mandrill', 'Sailboat on lake', 'Peppers', 'House'}; 

for k = 1:4
    raw = imresize(imread(img_paths{k}), [256, 256]);
    [In_Key] = generate_key(raw, Ex_Key, scale_factor);
    CIPHER_IMAGES{k} = encryption(raw, In_Key);
end

figure('Color', 'w', 'Position', [100, 100, 1200, 900]);
tlo = tiledlayout(4, 3, 'TileSpacing', 'compact', 'Padding', 'tight');

fprintf('\n结论：卡方检验结果 (临界值 = 284.34)\n');
fprintf('------------------------------------------------------------\n');
fprintf('%-15s | %-10s | %-10s | %-10s\n', 'Image', 'Chi-sq R', 'Chi-sq G', 'Chi-sq B');
fprintf('------------------------------------------------------------\n');

for i = 1:4
    curr_ci = CIPHER_IMAGES{i};
    channels = {'Red', 'Green', 'Blue'};
    colors = {[0.85, 0.33, 0.1], [0.47, 0.67, 0.19], [0, 0.45, 0.74]}; % R, G, B 标准色
    
    for c = 1:3
        ax = nexttile;
        data = curr_ci(:,:,c);
        [chi2_val, q, p_i] = calculate_metrics(data);
        
        
        bar(ax, 0:255, p_i, 'FaceColor', colors{c}, 'EdgeColor', 'none');
        hold on;
        plot(ax, [0 255], [q q], 'k--', 'LineWidth', 1.2);
        
        
        title(ax, sprintf('%s - %s (\\chi^2: %.2f)', IMG_NAMES{i}, channels{c}, chi2_val), 'FontSize', 9);
        grid on;
        if c == 1, ylabel(ax, 'Frequency'); end
        if i == 4, xlabel(ax, 'Gray Level'); end
        
        
        temp_chi(c) = chi2_val;
    end
    
    fprintf('%-15s | %-10.2f | %-10.2f | %-10.2f\n', ...
            IMG_NAMES{i}, temp_chi(1), temp_chi(2), temp_chi(3));
end
fprintf('------------------------------------------------------------\n');


function [chi2_val, q, p_i] = calculate_metrics(channel_data)
    [m, n] = size(channel_data);
    total_pixels = m * n;
    q = total_pixels / 256;
    p_i = imhist(uint8(channel_data));
    chi2_val = sum((p_i - q).^2 / q);
end