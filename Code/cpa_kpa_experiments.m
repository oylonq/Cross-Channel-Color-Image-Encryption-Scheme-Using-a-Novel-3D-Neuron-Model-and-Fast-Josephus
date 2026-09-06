%% 显式 CPA/KPA 抵抗性实验
% 通过选择极端明文（全黑、全白、棋盘、条纹等）并加密，验证密文的随机性以及
% 不同选择明文对应密文之间的差异性。

clc;
clear;
close all;

%% 路径设置
addpath('functions');
addpath('security_ performance_analysis');

%% 参数
imgSize = [512, 512, 3];
Ex_Key = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
scale_factor = 0.1;
rng default;

%% 构造选择明文
black     = zeros(imgSize, 'uint8');
white     = 255 * ones(imgSize, 'uint8');
checker   = build_checkerboard(imgSize);
hstripes  = build_hstripes(imgSize);
vstripes  = build_vstripes(imgSize);
red       = zeros(imgSize, 'uint8');
red(:, :, 1) = 255;

plainSet = {black, white, checker, hstripes, vstripes, red};
names    = {'Black', 'White', 'Checkerboard', 'H-Stripes', 'V-Stripes', 'Red'};

n = numel(plainSet);
CI   = cell(n, 1);
keys = cell(n, 1);

%% 加密每个选择明文
fprintf('===== CPA/KPA 实验：加密 %d 个选择明文 =====\n', n);
for i = 1:n
    fprintf('\n加密: %s\n', names{i});
    keys{i} = generate_key(plainSet{i}, Ex_Key, scale_factor);
    CI{i}   = encryption(plainSet{i}, keys{i});
end

%% 计算各密文的基本统计指标
fprintf('\n\n===== 各选择明文的密文指标 =====\n');
fprintf('%-18s %10s %12s %12s\n', 'Plaintext', 'Entropy', '|Corr|', 'Chi-square');
metrics = struct();
for i = 1:n
    ent   = avg_entropy(CI{i});
    corr  = avg_abs_correlation(CI{i});
    chi2  = avg_chi2(CI{i});
    metrics(i).name = names{i};
    metrics(i).entropy = ent;
    metrics(i).correlation = corr;
    metrics(i).chi2 = chi2;
    fprintf('%-18s %10.4f %12.4f %12.4f\n', names{i}, ent, corr, chi2);
end

%% 以 Black 为基准，计算两两密文之间的 NPCR/UACI（KPA/CPA 差异）
fprintf('\n\n===== 与 Black 密文的 NPCR/UACI =====\n');
fprintf('%-18s %10s %10s\n', 'Plaintext', 'NPCR(%)', 'UACI(%)');
for i = 2:n
    [NPCR, UACI] = differential(CI{1}, CI{i});
    npcr = mean(NPCR) * 100;
    uaci = mean(UACI) * 100;
    metrics(i).npcr_vs_black = npcr;
    metrics(i).uaci_vs_black = uaci;
    fprintf('%-18s %10.4f %10.4f\n', names{i}, npcr, uaci);
end

%% 生成 LaTeX 表格
latexTable = compose_cpa_table(metrics);
fprintf('\n\nLaTeX 表格代码：\n');
disp(latexTable);

outFile = 'cpa_kpa_results.txt';
fid = fopen(outFile, 'w');
if fid ~= -1
    fwrite(fid, latexTable, 'char');
    fclose(fid);
    fprintf('\nLaTeX 表格已保存至: %s\n', outFile);
end

save('cpa_kpa_results.mat', 'metrics', 'plainSet', 'CI', 'names', 'Ex_Key');

%% ==================== 局部辅助函数 ====================

function I = build_checkerboard(sz)
    I = zeros(sz, 'uint8');
    for k = 1:sz(3)
        for i = 1:sz(1)
            for j = 1:sz(2)
                if mod(i + j, 2) == 0
                    I(i, j, k) = 255;
                end
            end
        end
    end
end

function I = build_hstripes(sz)
    I = zeros(sz, 'uint8');
    for i = 1:sz(1)
        if mod(i, 4) < 2
            I(i, :, :) = 255;
        end
    end
end

function I = build_vstripes(sz)
    I = zeros(sz, 'uint8');
    for j = 1:sz(2)
        if mod(j, 4) < 2
            I(:, j, :) = 255;
        end
    end
end

function H = avg_entropy(I)
    Z = size(I, 3);
    H = 0;
    for k = 1:Z
        H = H + channel_entropy(I(:, :, k));
    end
    H = H / Z;
end

function H = channel_entropy(ch)
    ch = uint8(ch);
    counts = accumarray(double(ch(:)) + 1, 1, [256, 1]);
    p = counts / numel(ch);
    p = p(p > 0);
    H = -sum(p .* log2(p));
end

function c = avg_abs_correlation(I)
    [M, N, Z] = size(I);
    nSamples = 10000;
    sumAbsR = 0;
    count = 0;
    for k = 1:Z
        ch = double(I(:, :, k));
        i = randi(M, nSamples, 1);
        j = randi(N - 1, nSamples, 1);
        x = ch(sub2ind([M, N], i, j));
        y = ch(sub2ind([M, N], i, j + 1));
        rh = corr_coef(x, y);

        i = randi(M - 1, nSamples, 1);
        j = randi(N, nSamples, 1);
        x = ch(sub2ind([M, N], i, j));
        y = ch(sub2ind([M, N], i + 1, j));
        rv = corr_coef(x, y);

        i = randi(M - 1, nSamples, 1);
        j = randi(N - 1, nSamples, 1);
        x = ch(sub2ind([M, N], i, j));
        y = ch(sub2ind([M, N], i + 1, j + 1));
        rd = corr_coef(x, y);

        sumAbsR = sumAbsR + abs(rh) + abs(rv) + abs(rd);
        count = count + 3;
    end
    c = sumAbsR / count;
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

function chi2 = avg_chi2(I)
    Z = size(I, 3);
    chi2 = 0;
    for k = 1:Z
        chi2 = chi2 + chi2_channel(I(:, :, k));
    end
    chi2 = chi2 / Z;
end

function chi2 = chi2_channel(ch)
    ch = uint8(ch);
    counts = accumarray(double(ch(:)) + 1, 1, [256, 1]);
    expected = numel(ch) / 256;
    chi2 = sum((counts - expected).^2 / expected);
end

function tex = compose_cpa_table(metrics)
    nl = char(10);
    tex = sprintf('\\begin{table}[ht]');
    tex = [tex, sprintf('    \\centering'), nl];
    tex = [tex, sprintf('    \\caption{CPA/KPA resistance results for chosen-plaintext images ($512 \\times 512 \\times 3$).}'), nl];
    tex = [tex, sprintf('    \\label{TAB:CPA_KPA}'), nl];
    tex = [tex, sprintf('    \\begin{tabular}{l c c c c c}'), nl];
    tex = [tex, sprintf('        \\toprule'), nl];
    tex = [tex, sprintf('        \\textbf{Chosen plaintext} & \\textbf{Entropy} & \\textbf{Correlation} & \\textbf{Chi-square} & \\textbf{NPCR (\\%%)} & \\textbf{UACI (\\%%)} \\\\'), nl];
    tex = [tex, sprintf('        \\midrule'), nl];
    for i = 1:numel(metrics)
        name = metrics(i).name;
        if i == 1
            npcr_str = '--';
            uaci_str = '--';
        else
            npcr_str = sprintf('%.4f', metrics(i).npcr_vs_black);
            uaci_str = sprintf('%.4f', metrics(i).uaci_vs_black);
        end
        tex = [tex, sprintf('        %s & %.4f & %.4f & %.4f & %s & %s \\\\', ...
                            name, metrics(i).entropy, metrics(i).correlation, ...
                            metrics(i).chi2, npcr_str, uaci_str), nl];
    end
    tex = [tex, sprintf('        \\bottomrule'), nl];
    tex = [tex, sprintf('    \\end{tabular}'), nl];
    tex = [tex, sprintf('\\end{table}'), nl];
end
