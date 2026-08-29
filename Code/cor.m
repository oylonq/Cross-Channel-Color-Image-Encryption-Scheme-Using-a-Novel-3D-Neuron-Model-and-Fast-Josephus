clc;clear;

% 读取需要加密的图片
PI0 = imread("../Images/misc/4.2.03.tiff");
PI1 = imread("../Images/misc/4.2.06.tiff");
PI2 = imread("../Images/misc/4.2.07.tiff");
PI3 = imread("../Images/misc/house.tiff");

PI = {PI0,PI1,PI2,PI3};

% 生成内部密钥
Ex_Key0 = [0.1,0.1,0.1,0.1,0.1,0.1];
scale_factor = 0.1;
[In_Key0] = generate_key(PI0, Ex_Key0, scale_factor);


% 获取加密图像
[CI0] = encryption(PI0, In_Key0);
[CI1] = encryption(PI1, In_Key0);
[CI2] = encryption(PI2, In_Key0);
[CI3] = encryption(PI3, In_Key0);

CI = {CI0,CI1,CI2,CI3};


image_correlation_analysis(PI0);
image_correlation_analysis(CI0);

function r_xy = my_correlation(x, y)
% 确保输入转为 double 类型以防止溢出
x = double(x);
y = double(y);

% 1. 计算均值 (E(x) 和 E(y))
mean_x = mean(x);
mean_y = mean(y);

% 2. 计算分子：协方差部分 sum((xi - mean_x)*(yi - mean_y))
numerator = sum((x - mean_x) .* (y - mean_y));

% 3. 计算分母：标准差部分的乘积
denom_x = sum((x - mean_x).^2);
denom_y = sum((y - mean_y).^2);
denominator = sqrt(denom_x * denom_y);

% 4. 计算结果
if denominator == 0
  r_xy = 0; % 防止除以零
else
  r_xy = numerator / denominator;
end
end

function image_correlation_analysis(img)
% 1. 读取图像并转灰度
% img = imread('peppers.png'); % 替换为你的图片
if size(img, 3) == 3
  img = rgb2gray(img);
end

% 2. 随机选取 N 对像素
N = 3000; % 论文中通常取 2000 到 10000

% --- 计算三种方向的相关性 ---
fprintf('正在计算相关性...\n');
[h_corr, h_x, h_y] = get_correlation(img, N, 'horizontal');
[v_corr, v_x, v_y] = get_correlation(img, N, 'vertical');
[d_corr, d_x, d_y] = get_correlation(img, N, 'diagonal');

fprintf('水平相关性: %.4f\n', h_corr);
fprintf('垂直相关性: %.4f\n', v_corr);
fprintf('对角相关性: %.4f\n', d_corr);

% 3. 画散点图 (论文常见图表)
figure('Color', 'w', 'Position', [100, 100, 1200, 400]);

subplot(1, 3, 1); scatter(h_x, h_y, 5, 'filled');
title(['Horizontal: ' num2str(h_corr, '%.4f')]); xlabel('Pixel(x,y)'); ylabel('Pixel(x,y+1)');
axis([0 255 0 255]); axis square;

subplot(1, 3, 2); scatter(v_x, v_y, 5, 'filled');
title(['Vertical: ' num2str(v_corr, '%.4f')]); xlabel('Pixel(x,y)'); ylabel('Pixel(x+1,y)');
axis([0 255 0 255]); axis square;

subplot(1, 3, 3); scatter(d_x, d_y, 5, 'filled');
title(['Diagonal: ' num2str(d_corr, '%.4f')]); xlabel('Pixel(x,y)'); ylabel('Pixel(x+1,y+1)');
axis([0 255 0 255]); axis square;
end

% --- 核心计算函数 ---
function [r, vec_x, vec_y] = get_correlation(img, N, direction)
[rows, cols] = size(img);
vec_x = zeros(N, 1);
vec_y = zeros(N, 1);

count = 0;
while count < N
  % 随机选择坐标
  r_idx = randi([1, rows-1]); % 减1是为了防止越界
  c_idx = randi([1, cols-1]);

  % 提取当前点
  val_x = double(img(r_idx, c_idx));

  % 根据方向提取相邻点
  switch direction
    case 'horizontal' % 水平相邻 (x, y+1)
      val_y = double(img(r_idx, c_idx + 1));
    case 'vertical'   % 垂直相邻 (x+1, y)
      val_y = double(img(r_idx + 1, c_idx));
    case 'diagonal'   % 对角相邻 (x+1, y+1)
      val_y = double(img(r_idx + 1, c_idx + 1));
  end

  count = count + 1;
  vec_x(count) = val_x;
  vec_y(count) = val_y;
end

% 使用 MATLAB 内置公式计算相关系数
R_matrix = corrcoef(vec_x, vec_y);
r = R_matrix(1, 2);
end
