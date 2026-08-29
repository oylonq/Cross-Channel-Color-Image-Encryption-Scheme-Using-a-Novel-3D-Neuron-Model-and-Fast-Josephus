clc; clear; close all;


img_paths = {"../Images/misc/4.2.03.tiff", "../Images/misc/4.2.06.tiff", ...
             "../Images/misc/4.2.07.tiff", "../Images/misc/house.tiff"};
names = {'Mandrill', 'Sailboat', 'Peppers', 'House'};

Ex_Key = [1,-1,0.1,1.5,-1.5,0.2];
scale_factor = 0.01;


IMG = cell(1, 8);
IMG_NAMES = cell(1, 8);

for i = 1:4
    
    PI = imresize(imread(img_paths{i}), [512, 512]);
    
    In_Key = generate_key(PI, Ex_Key, scale_factor);
    CI = encryption(PI, In_Key);
    
    
    IMG{2*i - 1} = PI;
    IMG{2*i}     = CI;
    
    IMG_NAMES{2*i - 1} = [names{i}, ' (Plain)'];
    IMG_NAMES{2*i}     = [names{i}, ' (Cipher)'];
end


fprintf('\n%s\n', repmat('=', 1, 85));
fprintf('%-20s | %-5s | %-12s | %-12s | %-12s\n', 'Image Info', 'Ch', 'Horizontal', 'Vertical', 'Diagonal');
fprintf('%s\n', repmat('-', 1, 85));


for fig_idx = 1:2
    figure('Color', 'w', 'Position', [100 + 50*(fig_idx-1), 100 + 50*(fig_idx-1), 1400, 800]); 
    code = 97; % 97 对应字母 'a'
    pos = 1;
    
   
    start_idx = (fig_idx - 1) * 4 + 1;
    end_idx = start_idx + 3;
    
    for i = start_idx:end_idx
        img = IMG{i};
        current_name = IMG_NAMES{i};
        
        
        ax_img = subplot(4, 4, pos);
        imshow(img);
        add_label(ax_img, code);
       
        
        code = code + 1; pos = pos + 1;
        
       
        channel_colors = {[1,0,0], [0,1,0], [0,0,1]};
        channel_names = {'R', 'G', 'B'};
        
        for c = 1:3
            ax_scat = subplot(4, 4, pos);
            
            corrs = draw_and_calculate(ax_scat, img(:,:,c), channel_colors{c});
            add_label(ax_scat, code);
            
            
            row_title = ''; 
            if c == 1
                row_title = current_name; 
            end
            fprintf('%-20s | %-5s | %-12.4f | %-12.4f | %-12.4f\n', ...
                    row_title, channel_names{c}, corrs(1), corrs(2), corrs(3));
                    
            code = code + 1; pos = pos + 1;
        end
        fprintf('%s\n', repmat('-', 1, 85));
    end
end


function corrs = draw_and_calculate(ax, channel_data, color_rgb)
    % 1. 向量化提取数据 (快于 while 循环)
    N = 10000;
    channel_data = double(channel_data);
    [rows, cols] = size(channel_data);
    
    % 随机采样 N 个点
    r_idx = randi([1, rows-1], N, 1);
    c_idx = randi([1, cols-1], N, 1);
    linear_idx = (c_idx-1)*rows + r_idx;
    
    x = channel_data(linear_idx);
    h_y = channel_data(linear_idx + rows); % (r, c+1)
    v_y = channel_data(linear_idx + 1);    % (r+1, c)
    d_y = channel_data(linear_idx + rows + 1); % (r+1, c+1)
    
    % 2. 计算相关系数
    c_h = corrcoef(x, h_y); h_corr = c_h(1,2);
    c_v = corrcoef(x, v_y); v_corr = c_v(1,2);
    c_d = corrcoef(x, d_y); d_corr = c_d(1,2);
    corrs = [h_corr, v_corr, d_corr];
    
    % 3. 3D 绘图
    hold(ax, 'on');
    scatter3(ax, x, zeros(N,1), h_y, 1, color_rgb, 'filled');
    scatter3(ax, x, ones(N,1)*100, v_y, 1, color_rgb, 'filled');
    scatter3(ax, x, ones(N,1)*200, d_y, 1, color_rgb, 'filled');
    
    % 4. 美化
    grid(ax, 'on'); box(ax, 'on');
    set(ax, 'XLim', [0 255], 'ZLim', [0 255], 'YLim', [-20 220]);
    set(ax, 'YTick', [0, 100, 200], 'YTickLabel', {'H','V','D'}, 'FontSize', 8);
    set(ax, 'XDir', 'reverse');
    xlabel(ax, 'P1'); zlabel(ax, 'P2');
    view(ax, 45, 30);
end

function add_label(ax, code)
    text(ax, 0.5, -0.15, ['(', char(code), ')'], 'Units', 'normalized', ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end