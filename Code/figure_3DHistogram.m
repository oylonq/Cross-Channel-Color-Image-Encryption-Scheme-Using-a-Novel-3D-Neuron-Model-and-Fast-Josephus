clc;clear;

image_paths = {"../Images/misc/4.2.03.tiff", "../Images/misc/4.2.06.tiff", ...
               "../Images/misc/4.2.07.tiff", "../Images/misc/house.tiff"};
num_imgs = length(image_paths);
PI = cell(1, num_imgs);
CI = cell(1, num_imgs);

% 外部密钥与参数
Ex_Key0 = [1, -1, 0.1, 1.5, -1.5, 0.2];
scale_factor = 0.2;

% 循环处理图像
for i = 1:num_imgs
    img = imread(image_paths{i});
    PI{i} = imresize(img, [256, 256]);
    
    
    if i == 1
        [In_Key0] = generate_key(PI{i}, Ex_Key0, scale_factor);
    end
    CI{i} = encryption(PI{i}, In_Key0);
end

fig = figure(1);
set(fig, 'Color', 'w', 'Position', [100, 100, 1000, 800]); % 设置白色背景和窗口大小
tlo = tiledlayout(4, 4, 'TileSpacing', 'compact', 'Padding', 'tight');

code_idx = 0; % 用于生成 (a), (b), (c)...
labels = cellstr(char(97:97+15)'); % 预生成 a-p 的标签

for i = 1:num_imgs
    % --- 原始图像 ---
    nexttile;
    imshow(PI{i});
    draw_label(labels{code_idx + 1});
    
    % --- 原始直方图 ---
    nexttile;
    plotRGBHistogram3D_Enhanced(PI{i});
    draw_label(labels{code_idx + 2});
    
    % --- 加密图像 ---
    nexttile;
    imshow(CI{i});
    draw_label(labels{code_idx + 3});
    
    % --- 加密直方图 ---
    nexttile;
    plotRGBHistogram3D_Enhanced(CI{i});
    draw_label(labels{code_idx + 4});
    
    code_idx = code_idx + 4;
end

function plotRGBHistogram3D_Enhanced(img)
   
    colors = [0.90, 0.35, 0.10; 
          0.45, 0.75, 0.20; 
          0.00, 0.45, 0.75];
    
    hold on; grid on;
    x = 0:255;
    
    for c = 1:3
        counts = imhist(img(:,:,c));
        
        fill3([x, fliplr(x)], ...
              (c-1) * ones(1, 512), ...
              [counts', zeros(1, 256)], ...
              colors(c,:), ...
              'FaceAlpha', 0.6, ...
              'EdgeColor', colors(c,:), ...
              'LineWidth', 0.5);
    end
    
    
    view(55, 35); 
    box on;
    set(gca, 'FontSize', 9, 'LineWidth', 0.8, 'GridAlpha', 0.1);
    set(gca, 'XTick', [0, 128, 255], 'YTick', [0 1 2], 'YTickLabel', {'R', 'G', 'B'});
    xlim([0, 255]);
    zlabel('Count', 'FontWeight', 'bold');
    
    
    ztickformat('%g'); 
end

function draw_label(txt)
    xlabel(['(', txt, ')'], 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
end