clc;clear;

Ex_Key0 = [1,-1,0.1,1.5,-1.5,0.2];
scale_factor = 0.2;

% 读取需要加密的图片
PI = imread("../Images/misc/4.2.03.tiff");
PI = imresize(PI, [256, 256]);
% 生成内部密钥
[In_Key0] = generate_key(PI, Ex_Key0, scale_factor);

% 加密敏感性
In_Key1 = In_Key0;
In_Key2 = In_Key0;
In_Key3 = In_Key0;

In_Key1(1)= In_Key1(1) + 10^(-15);
In_Key2(2)= In_Key2(2) + 10^(-15);
In_Key3(3)= In_Key3(3) + 10^(-15);

% 获取加密图像
[CI0] = encryption(PI, In_Key0);
[CI1] = encryption(PI, In_Key1);
[CI2] = encryption(PI, In_Key2);
[CI3] = encryption(PI, In_Key3);
[~,~,AvgNPCR_key0_0,~] = differential(CI0, CI0);
[~,~,AvgNPCR_key0_1,~] = differential(CI0, CI1);
[~,~,AvgNPCR_key0_2,~] = differential(CI0, CI2);
[~,~,AvgNPCR_key0_3,~] = differential(CI0, CI3);

disp(["AvgNPCR_key0_0:",num2str(AvgNPCR_key0_0*100)+"%"]);
disp(["AvgNPCR_key0_1:",num2str(AvgNPCR_key0_1*100)+"%"]);
disp(["AvgNPCR_key0_2:",num2str(AvgNPCR_key0_2*100)+"%"]);
disp(["AvgNPCR_key0_3:",num2str(AvgNPCR_key0_3*100)+"%"]);

[~,~,AvgNPCR_key1_0,~] = differential(CI1, CI0);
[~,~,AvgNPCR_key1_1,~] = differential(CI1, CI1);
[~,~,AvgNPCR_key1_2,~] = differential(CI1, CI2);
[~,~,AvgNPCR_key1_3,~] = differential(CI1, CI3);

disp(["AvgNPCR_key1_0:",num2str(AvgNPCR_key1_0*100)+"%"]);
disp(["AvgNPCR_key1_1",num2str(AvgNPCR_key1_1*100)+"%"]);
disp(["AvgNPCR_key1_2:",num2str(AvgNPCR_key1_2*100)+"%"]);
disp(["AvgNPCR_key1_3:",num2str(AvgNPCR_key1_3*100)+"%"]);

[~,~,AvgNPCR_key2_0,~] = differential(CI2, CI0);
[~,~,AvgNPCR_key2_1,~] = differential(CI2, CI1);
[~,~,AvgNPCR_key2_2,~] = differential(CI2, CI2);
[~,~,AvgNPCR_key2_3,~] = differential(CI2, CI3);

disp(["AvgNPCR_key2_0:",num2str(AvgNPCR_key2_0*100)+"%"]);
disp(["AvgNPCR_key2_1",num2str(AvgNPCR_key2_1*100)+"%"]);
disp(["AvgNPCR_key2_2:",num2str(AvgNPCR_key2_2*100)+"%"]);
disp(["AvgNPCR_key2_2:",num2str(AvgNPCR_key2_3*100)+"%"]);

[~,~,AvgNPCR_key3_0,~] = differential(CI3, CI0);
[~,~,AvgNPCR_key3_1,~] = differential(CI3, CI1);
[~,~,AvgNPCR_key3_2,~] = differential(CI3, CI2);
[~,~,AvgNPCR_key3_3,~] = differential(CI3, CI3);

disp(["AvgNPCR_key3_0:",num2str(AvgNPCR_key3_0*100)+"%"]);
disp(["AvgNPCR_key3_1",num2str(AvgNPCR_key3_1*100)+"%"]);
disp(["AvgNPCR_key3_2:",num2str(AvgNPCR_key3_2*100)+"%"]);
disp(["AvgNPCR_key3_3:",num2str(AvgNPCR_key3_3*100)+"%"]);

figure(1);
% subplot(2,4,1);
% imshow(CI0);
% xlabel('(a)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,2);
% imshow(CI1);
% xlabel('(b)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,3);
% imshow(CI2);
% xlabel('(c)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,4);
% imshow(CI3);
% xlabel('(d)', 'FontSize', 12, 'FontWeight', 'bold');
% 使用 tiledlayout 替代 subplot，设置紧凑布局
t = tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'tight'); 
% --- 第一行：加密图像 ---
nexttile; imshow(CI0);
xlabel('(a)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(CI1);
xlabel('(b)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(CI2);
xlabel('(c)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(CI3);
xlabel('(d)', 'FontSize', 12, 'FontWeight', 'bold');



% 解密敏感性
In_Key4 = In_Key0;
In_Key5 = In_Key0;
In_Key6 = In_Key0;

In_Key4(4)= In_Key4(4) + 10^(-15);
In_Key5(5)= In_Key5(5) + 10^(-15);
In_Key6(6)= In_Key6(6) + 10^(-15);

[DI0] = decryption(CI0,In_Key0);
[DI1] = decryption(CI0,In_Key4);
[DI2] = decryption(CI0,In_Key5);
[DI3] = decryption(CI0,In_Key6);

% subplot(2,4,5);
% imshow(DI0);
% xlabel('(e)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,6);
% imshow(DI1);
% xlabel('(f)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,7);
% imshow(DI2);
% xlabel('(g)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% subplot(2,4,8);
% imshow(DI3);
% xlabel('(h)', 'FontSize', 12, 'FontWeight', 'bold');
% --- 第二行：解密图像 ---
nexttile; imshow(DI0);
xlabel('(e)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(DI1);
xlabel('(f)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(DI2);
xlabel('(g)', 'FontSize', 12, 'FontWeight', 'bold');

nexttile; imshow(DI3);
xlabel('(h)', 'FontSize', 12, 'FontWeight', 'bold');



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