function plotRGBHistogram3D(img)
% 1. 分离通道并计算直方图
[rCounts, ~] = imhist(img(:,:,1));
[gCounts, ~] = imhist(img(:,:,2));
[bCounts, ~] = imhist(img(:,:,3));

x = 0:255; % 灰度级 0-255

hold on; grid on;

plot3(x, zeros(1, 256), rCounts, 'r', 'LineWidth', 1);
plot3(x, ones(1, 256), gCounts, 'g', 'LineWidth', 1);
plot3(x, 2*ones(1, 256), bCounts, 'b', 'LineWidth', 1);


fill3([x, fliplr(x)], [zeros(1,256), zeros(1,256)], [rCounts', zeros(1,256)], 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'r');
fill3([x, fliplr(x)], [ones(1,256), ones(1,256)], [gCounts', zeros(1,256)], 'g', 'FaceAlpha', 0.5, 'EdgeColor', 'g');
fill3([x, fliplr(x)], [2*ones(1,256), 2*ones(1,256)], [bCounts', zeros(1,256)], 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'b');

% 4. 设置坐标轴和视角
view(45, 30); % 调整观察角度
set(gca, 'XTick', [100, 200, 255]);
set(gca, 'XTickLabelRotation', 0);
xlim([0,255]);
set(gca, 'YTick', [0 1 2], 'YTickLabel', {'R', 'G', 'B'});
% xlabel('像素亮度值');
% ylabel('通道');
% zlabel('频率 (Frequency)');
% title('RGB 3D 直方图');
end
