clear; clc;

a = 1; b = 3; c = 1; d = 2; I = 1; MT = 1;

k_span = 2:0.002:3; 

LE_results = zeros(length(k_span), 3);
y_start = [0.1; 0.1; 0.1];

fprintf('开始计算李雅普诺夫指数光谱...\n');

for i = 1:length(k_span)
    k_current = k_span(i);
    
    [T, Lexp] = lyapunov(3, @(t, X) sys_ext_flow(t, X, a, b, c, d, I, k_current, MT), ...
                         @ode45, 0, 0.5, 500, y_start, 0);
      
    LE_results(i, :) = Lexp(end, :);
    
   
    if mod(i, 10) == 0
        fprintf('已完成: %.2f%%\n', (i/length(k_span))*100);
        
    end
end

figure('Color', 'w', 'Name', 'Lyapv Exp Diagram','Units', 'pixels', 'Position', [150, 150, 800, 500]);
hold on; box on;


line([min(k_span), max(k_span)], [0, 0], 'Color', [0.5 0.5 0.5], ...
    'LineStyle', '--', 'LineWidth', 1.2, 'HandleVisibility', 'off');


plot(k_span, LE_results(:, 1), 'r-', 'LineWidth', 1.5, 'DisplayName', '$LE_1$'); % 最大指数
plot(k_span, LE_results(:, 2), 'k-', 'LineWidth', 1.2, 'DisplayName', '$LE_2$'); % 第二指数



set(gca, 'FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.1, 'TickDir', 'in');
xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Lyapunov exponents', 'Interpreter', 'latex', 'FontSize', 14);


axis([2 3 -0.3 0.2]); 
xticks(2:0.1:3); 


legend('Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
grid on; 
ax = gca;
ax.GridLineStyle = ':';
ax.GridAlpha = 0.5;

fprintf('绘图完成，建议导出为 PDF 矢量格式以获得最佳印刷效果。\n');