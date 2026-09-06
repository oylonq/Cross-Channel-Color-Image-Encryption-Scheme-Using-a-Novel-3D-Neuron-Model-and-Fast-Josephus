%% 跨通道 RGB 相关性分析
% 计算明文图像和密文图像在同一空间位置处 R-G、R-B、G-B 像素值之间的相关系数。
% 强加密方案应使密文的跨通道相关度接近于 0。

clc;
clear;
close all;

%% 路径设置
addpath('functions');
addpath('security_ performance_analysis');

%% 实验参数
img_paths = {"../Images/misc/4.2.03.tiff", ...
             "../Images/misc/4.2.06.tiff", ...
             "../Images/misc/4.2.07.tiff", ...
             "../Images/misc/house.tiff"};
names = {'Mandrill', 'Sailboat', 'Peppers', 'House'};
Ex_Key = [1, -1, 0.1, 1.5, -1.5, 0.2];
scale_factor = 0.01;
target_size = [512, 512];
nSamples = 10000;

rng default;

%% 计算各图像的跨通道相关度
nImg = numel(names);
pairs = {'R-G', 'R-B', 'G-B'};
plain_corr = zeros(nImg, 3);
cipher_corr = zeros(nImg, 3);

fprintf('\n===== 跨通道 RGB 相关性分析 =====\n');
fprintf('%-12s %-8s %-12s %-12s\n', 'Image', 'Pair', 'Plaintext', 'Ciphertext');
for i = 1:nImg
    PI = imresize(imread(img_paths{i}), target_size);
    In_Key = generate_key(PI, Ex_Key, scale_factor);
    CI = encryption(PI, In_Key);

    for p = 1:3
        switch pairs{p}
            case 'R-G'
                c1 = 1; c2 = 2;
            case 'R-B'
                c1 = 1; c2 = 3;
            case 'G-B'
                c1 = 2; c2 = 3;
        end
        plain_corr(i, p) = cross_channel_corr(PI, c1, c2, nSamples);
        cipher_corr(i, p) = cross_channel_corr(CI, c1, c2, nSamples);
        fprintf('%-12s %-8s %-12.4f %-12.4f\n', names{i}, pairs{p}, ...
                plain_corr(i, p), cipher_corr(i, p));
    end
end

%% 生成 LaTeX 表格
latexTable = compose_cross_channel_table(names, pairs, plain_corr, cipher_corr);
fprintf('\n\nLaTeX 表格代码：\n');
disp(latexTable);

outFile = 'cross_channel_correlation.txt';
fid = fopen(outFile, 'w');
if fid ~= -1
    fwrite(fid, latexTable, 'char');
    fclose(fid);
    fprintf('\nLaTeX 表格已保存至: %s\n', outFile);
end

save('cross_channel_correlation.mat', 'names', 'pairs', 'plain_corr', 'cipher_corr');

%% ==================== 局部辅助函数 ====================

function r = cross_channel_corr(I, c1, c2, N)
    [M, Ndim, ~] = size(I);
    x = double(reshape(I(:, :, c1), [], 1));
    y = double(reshape(I(:, :, c2), [], 1));
    idx = randperm(M * Ndim, N);
    r = corr_coef(x(idx), y(idx));
end

function r = corr_coef(x, y)
    x = double(x(:));
    y = double(y(:));
    mx = mean(x);
    my = mean(y);
    num = sum((x - mx) .* (y - my));
    den = sqrt(sum((x - mx).^2) * sum((y - my).^2));
    if den == 0
        r = 0;
    else
        r = num / den;
    end
end

function tex = compose_cross_channel_table(names, pairs, plain_corr, cipher_corr)
    nl = char(10);
    tex = sprintf('\\begin{table}[ht]');
    tex = [tex, sprintf('    \\centering'), nl];
    tex = [tex, sprintf('    \\caption{Cross-channel correlation coefficients for plaintext and ciphertext images ($512 \\times 512 \\times 3$).}'), nl];
    tex = [tex, sprintf('    \\label{TAB:CrossChannelCor}'), nl];
    tex = [tex, sprintf('    \\begin{tabular}{l l c c}'), nl];
    tex = [tex, sprintf('        \\toprule'), nl];
    tex = [tex, sprintf('        \\textbf{Image} & \\textbf{Pair} & \\textbf{Plaintext} & \\textbf{Ciphertext} \\\\'), nl];
    tex = [tex, sprintf('        \\midrule'), nl];
    for i = 1:numel(names)
        for p = 1:numel(pairs)
            if p == 1
                imgName = names{i};
            else
                imgName = '';
            end
            tex = [tex, sprintf('        %s & %s & %.4f & %.4f \\\\', ...
                                imgName, pairs{p}, plain_corr(i, p), cipher_corr(i, p)), nl];
        end
        if i < numel(names)
            tex = [tex, sprintf('        \\midrule'), nl];
        end
    end
    tex = [tex, sprintf('        \\bottomrule'), nl];
    tex = [tex, sprintf('    \\end{tabular}'), nl];
    tex = [tex, sprintf('\\end{table}'), nl];
end
