clc; clear; close all;


img_paths = {"../Images/misc/4.2.03.tiff", "../Images/misc/4.2.06.tiff", ...
             "../Images/misc/4.2.07.tiff", "../Images/misc/house.tiff"};
names = {'Mandrill', 'Sailboat', 'Peppers', 'House'};
Ex_Key = [1,-1,0.1,1.5,-1.5,0.2];
scale_factor = 0.2;


results = struct();


fprintf('正在处理图像并计算 NPCR/UACI，请稍候...\n');

for i = 1:4
    PI1 = imresize(imread(img_paths{i}), [256, 256]);
    
    % 生成差分图像
    PI2 = PI1;
    r = randi([1, 256]); c = randi([1, 256]); ch = randi([1, 3]);
    if PI2(r, c, ch) == 255, PI2(r, c, ch) = 254; else PI2(r, c, ch) = PI2(r, c, ch) + 1; end
    
    % 加密（此时控制台可能会打印耗时，我们先不管它）
    In_Key1 = generate_key(PI1, Ex_Key, scale_factor);
    CI1 = encryption(PI1, In_Key1);
    
    In_Key2 = generate_key(PI2, Ex_Key, scale_factor);
    CI2 = encryption(PI2, In_Key2);
    
    % 计算 NPCR/UACI
    [NPCR, UACI, AvgN, AvgU] = differential(CI1, CI2);
    
    % 存储结果
    results(i).name = names{i};
    results(i).NPCR = NPCR * 100;
    results(i).UACI = UACI * 100;
    results(i).AvgN = AvgN * 100;
    results(i).AvgU = AvgU * 100;
end

fprintf('\n%s\n', repmat('=', 1, 85));
fprintf('%-15s | %-5s | %-15s | %-15s | %-20s\n', 'Image', 'Ch', 'NPCR (%)', 'UACI (%)', 'Average (%)');
fprintf('%s\n', repmat('-', 1, 85));

for i = 1:4
    ch_names = {'R', 'G', 'B'};
    for j = 1:3
        name_str = ''; if j == 1, name_str = results(i).name; end
        
        if j == 1
            fprintf('%-15s | %-5s | %-15.4f | %-15.4f | \n', ...
                name_str, ch_names{j}, results(i).NPCR(j), results(i).UACI(j));
        elseif j == 2
            fprintf('%-15s | %-5s | %-15.4f | %-15.4f | Avg NPCR: %.4f\n', ...
                '', ch_names{j}, results(i).NPCR(j), results(i).UACI(j), results(i).AvgN);
        else
            fprintf('%-15s | %-5s | %-15.4f | %-15.4f | Avg UACI: %.4f\n', ...
                '', ch_names{j}, results(i).NPCR(j), results(i).UACI(j), results(i).AvgU);
        end
    end
    fprintf('%s\n', repmat('-', 1, 85));
end


function [NPCR_vals, UACI_vals, AvgNPCR, AvgUACI] = differential(C1, C2)
    C1 = double(C1);
    C2 = double(C2);
    [M, N, ~] = size(C1);
    
    
    diff_matrix = (C1 ~= C2);
    NPCR_vals = sum(sum(diff_matrix, 1), 2) / (M * N);
    NPCR_vals = squeeze(NPCR_vals)'; % 转换为 1x3 向量
    
    % 2. 向量化计算 UACI
    abs_diff = abs(C1 - C2);
    UACI_vals = sum(sum(abs_diff, 1), 2) / (M * N * 255);
    UACI_vals = squeeze(UACI_vals)'; % 转换为 1x3 向量
    
    % 3. 计算平均值
    AvgNPCR = mean(NPCR_vals);
    AvgUACI = mean(UACI_vals);
end