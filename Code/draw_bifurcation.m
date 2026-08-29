clear; clc; close all;

a = 1; b = 3; c = 1; d = 2; I = 1; MT = 1;

k_span = 1.9:0.0005:3; 

X0 = [0.1; 0.1; 0.5];

t_transient = [0 500]; 
t_steady = 0:0.1:300;  

K_plot = [];
X_plot = [];

fprintf('开始计算高精度分岔图数据...\n');

for i = 1:length(k_span)
    k_current = k_span(i);
    
   
    [~, X_trans] = ode45(@(t, X) hr_system(t, X, a, b, c, d, I, k_current, MT), t_transient, X0);
    X0 = X_trans(end, :)'; 
    
    
    [~, X_steady] = ode45(@(t, X) hr_system(t, X, a, b, c, d, I, k_current, MT), t_steady, X0);
    x_series = X_steady(:, 1);
    
    
    idx = find(x_series(2:end-1) > x_series(1:end-2) & x_series(2:end-1) > x_series(3:end)) + 1;
    pks = x_series(idx);
    
    
    K_plot = [K_plot; k_current * ones(length(pks), 1)];
    X_plot = [X_plot; pks];
    
    if mod(i, 50) == 0
        fprintf('已完成: %.2f%%\n', (i/length(k_span))*100);
    end
end

fprintf('计算完成，正在渲染期刊级图表...\n');

fig = figure('Color', 'w', 'Name', 'High-Res Bifurcation Diagram');

fig.Position = [100, 100, 700, 450]; 

scatter(K_plot, X_plot, 1.5, [0, 0.2, 0.6], 'filled', ...
    'MarkerFaceAlpha', 0.15, 'MarkerEdgeAlpha', 0.15);

xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Times New Roman'); 
ylabel('Local Maxima of $x$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Times New Roman');

axis([1.9, 3, min(X_plot)-0.2, max(X_plot)+0.2]); 

ax = gca;
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
ax.LineWidth = 1.2;      
ax.TickDir = 'in';       
ax.XMinorTick = 'on';    
ax.YMinorTick = 'on';
ax.Box = 'on';           

ax.GridLineStyle = ':';  
ax.GridAlpha = 0.4;
grid on;

function dX = hr_system(~, X, a, b, c, d, I, k, MT)
    x = X(1); 
    y = X(2); 
    phi = X(3);
    dX = zeros(3, 1);
    dX(1) = y - a*x^3 + b*x^2 + I - k*phi*x;
    dX(2) = c - d*x^2 - y;
    dX(3) = k*(1 - x/MT)*phi*(1 - phi);
end