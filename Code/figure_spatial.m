clc;clear;
img_paths = {"../Images/misc/house.tiff", "../Images/misc/4.2.06.tiff", ...
             "../Images/misc/4.2.03.tiff", "../Images/misc/4.2.07.tiff"};

% 预处理与加密逻辑
Ex_Key = [1, -1, 0.1, 1.5, -1.5, 0.2];
scale_factor = 0.2;

PI = cell(1, 4);
CI = cell(1, 4);

for k = 1:4
    img = imresize(imread(img_paths{k}), [256, 256]);
    PI{k} = img;
    % 为每张图生成独立密钥并加密
    [In_Key] = generate_key(img, Ex_Key, scale_factor);
    CI{k} = encryption(img, In_Key);
end


FIG_GROUPS = {{PI{1}, CI{1}, PI{2}, CI{2}}, ...
              {PI{3}, CI{3}, PI{4}, CI{4}}};

CMAPS = {'autumn', 'summer', 'winter'}; 

for g = 1:2
    current_rows = FIG_GROUPS{g};
    
    
    fig = figure('Name', ['Intensity Distribution Set ', num2str(g)], ...
                 'Color', 'w', 'Position', [100, 50, 1000, 1000]);
    tlo = tiledlayout(4, 4, 'TileSpacing', 'compact', 'Padding', 'tight');
    
    label_code = 97; % 每一张大图都从 (a) 开始
    
    for r = 1:4
        curr_img = current_rows{r};
        
        % --- 第 1 列：2D 图像展示 ---
        ax = nexttile;
        imshow(curr_img);
        add_sublabel(ax, char(label_code));
        label_code = label_code + 1;
        
        % --- 第 2-4 列：R, G, B 3D 像素分布图 ---
        for channel = 1:3
            ax = nexttile;
            draw_distribution_v3(ax, curr_img(:,:,channel), CMAPS{channel});
            add_sublabel(ax, char(label_code));
            label_code = label_code + 1;
        end
    end
    
   
end


function draw_distribution_v3(ax, data, cmap)
    Z = double(data);
    [rows, cols] = size(Z);
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % 底部投影平面
    surf(ax, X, Y, zeros(rows, cols), Z, 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    hold(ax, 'on');
    
    % 3D 分布曲面
    surf(ax, X, Y, Z, Z, 'EdgeColor', 'none'); 
    shading(ax, 'interp'); 
    
    % 视角与对齐
    set(ax, 'YDir', 'reverse'); % 反转Y轴匹配图像索引
    % === 反转 X 轴 ===
    set(ax, 'XDir', 'reverse');
    view(ax, 135, 30);          
    
    % 坐标轴设置
    grid(ax, 'on'); box(ax, 'on');
    xlim(ax, [0 256]); ylim(ax, [0 256]); zlim(ax, [0 255]);
    set(ax, 'XTick', [0 128 256], 'YTick', [0 128 256], 'ZTick', [0 128 255]);
    set(ax, 'FontSize', 8);
    
    xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Intensity');
    colormap(ax, cmap);
    pbaspect(ax, [1 1 0.7]);
end

function add_sublabel(ax, txt)
    text(ax, 0.5, -0.05, ['(', txt, ')'], ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 12, 'FontWeight', 'bold');
end