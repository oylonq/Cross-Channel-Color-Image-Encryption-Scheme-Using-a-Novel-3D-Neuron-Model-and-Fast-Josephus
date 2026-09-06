%% 消融实验主脚本
% 对比完整方案与若干去掉/替换核心模块后的变体，并输出安全指标。
% 运行前请确保当前工作目录为 .../PaperCode/Code，或在本脚本所在目录运行。

clc;
clear;
close all;

%% 路径设置
addpath('functions');
addpath('security_ performance_analysis');

%% 实验参数
imgPath = '../Images/misc/4.2.07.tiff';   % 512 x 512 彩色测试图（可改为 Peppers/其它）
Ex_Key = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; % 外部密钥
scale_factor = 0.1;

rng default;  % 便于复现相关性采样

%% 读取图像
PI = imread(imgPath);
[M, N, Z] = size(PI);
if Z ~= 3
    error('本脚本需要 RGB 彩色图像。');
end
fprintf('消融实验图像: %s, 尺寸: %d x %d x %d\n', imgPath, M, N, Z);

%% 构造用于 NPCR/UACI 的微改明文
PI2 = PI;
PI2(1, 1, 1) = mod(double(PI2(1, 1, 1)) + 1, 256);

%% 配置各消融变体
configs = {
    'Full proposed scheme',      'full';
    'w/o CMJA scrambling',       'no_cmja';
    'w/o CLMM',                  'no_clmm';
    'w/o diffusion phase',       'no_diffusion';
    'w/o plaintext-related key', 'full';
};

nConfig = size(configs, 1);
results = struct();

%% 逐组加密并计算指标
for i = 1:nConfig
    label = configs{i, 1};
    mode  = configs{i, 2};
    fprintf('\n===== %s =====\n', label);

    if contains(label, 'plaintext-related')
        % 去掉明文相关密钥：直接用 Ex_Key 作为初始密钥
        In_Key_A = Ex_Key;
        In_Key_B = Ex_Key;
    else
        In_Key_A = generate_key(PI, Ex_Key, scale_factor);
        In_Key_B = generate_key(PI2, Ex_Key, scale_factor);
    end

    CI_A = encryption_ablation(PI, In_Key_A, mode);
    CI_B = encryption_ablation(PI2, In_Key_B, mode);

    % 计算指标
    ent  = avg_entropy(CI_A);
    corr = avg_abs_correlation(CI_A);
    [NPCR, UACI] = differential(CI_A, CI_B);
    npcr = mean(NPCR) * 100;
    uaci = mean(UACI) * 100;

    results(i).label = label;
    results(i).entropy = ent;
    results(i).correlation = corr;
    results(i).NPCR = npcr;
    results(i).UACI = uaci;

    fprintf('Entropy = %.4f, |Correlation| = %.4f, NPCR = %.4f%%, UACI = %.4f%%\n', ...
            ent, corr, npcr, uaci);
end

%% 汇总打印表格
fprintf('\n\n===== 消融实验结果汇总 =====\n');
fprintf('%-35s %10s %12s %10s %10s\n', 'Configuration', 'Entropy', '|Corr|', 'NPCR(%)', 'UACI(%)');
for i = 1:nConfig
    fprintf('%-35s %10.4f %12.4f %10.4f %10.4f\n', ...
            results(i).label, results(i).entropy, results(i).correlation, ...
            results(i).NPCR, results(i).UACI);
end

%% 生成 LaTeX 表格并保存
latexTable = compose_latex_table(results, M, N);
disp(' ');
disp('LaTeX 表格代码：');
disp(latexTable);

outFile = 'ablation_results.txt';
fid = fopen(outFile, 'w');
if fid ~= -1
    fwrite(fid, latexTable, 'char');
    fclose(fid);
    fprintf('\nLaTeX 表格已保存至: %s\n', outFile);
end

%% 保存数值到 MAT
save('ablation_results.mat', 'results', 'configs', 'imgPath', 'Ex_Key');

%% ==================== 局部辅助函数 ====================

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
        % 水平
        i = randi(M, nSamples, 1);
        j = randi(N - 1, nSamples, 1);
        x = ch(sub2ind([M, N], i, j));
        y = ch(sub2ind([M, N], i, j + 1));
        rh = corr_coef(x, y);
        % 垂直
        i = randi(M - 1, nSamples, 1);
        j = randi(N, nSamples, 1);
        x = ch(sub2ind([M, N], i, j));
        y = ch(sub2ind([M, N], i + 1, j));
        rv = corr_coef(x, y);
        % 对角
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

function tex = compose_latex_table(results, M, N)
    nl = char(10);
    tex = sprintf('\\begin{table}[ht]');
    tex = [tex, sprintf('    \\centering'), nl];
    tex = [tex, sprintf('    \\caption{Ablation study results on the test image ($%d \\times %d \\times 3$).}', M, N), nl];
    tex = [tex, sprintf('    \\label{TAB:Ablation}'), nl];
    tex = [tex, sprintf('    \\begin{tabular}{l c c c c}'), nl];
    tex = [tex, sprintf('        \\toprule'), nl];
    tex = [tex, sprintf('        \\textbf{Configuration} & \\textbf{Entropy} & \\textbf{Correlation} & \\textbf{NPCR (\\%%)} & \\textbf{UACI (\\%%)} \\\\'), nl];
    tex = [tex, sprintf('        \\midrule'), nl];
    for i = 1:numel(results)
        label = results(i).label;
        label = strrep(label, '%', '\\%%');
        tex = [tex, sprintf('        %s & %.4f & %.4f & %.4f & %.4f \\\\', ...
                            label, results(i).entropy, results(i).correlation, ...
                            results(i).NPCR, results(i).UACI), nl];
    end
    tex = [tex, sprintf('        \\bottomrule'), nl];
    tex = [tex, sprintf('    \\end{tabular}'), nl];
    tex = [tex, sprintf('\\end{table}'), nl];
end
