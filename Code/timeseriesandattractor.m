clc; clear; close all;

a = 1; b = 3; c = 1; d = 2; I = 1; k = 2.8; MT = 1;
Y0 = [0.1169282607, 0.03563851071, 0.01034665217];
TStart = 0; TEnd = 800; 
h = 0.01; 
tspan = TStart:h:TEnd;


options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
[T, Y] = ode45(@(t, Y) hrnm(t, Y, a, b, c, d, I, k, MT), tspan, Y0, options);

discard_pts = floor(length(T) * 0.25); 
Y_plot = Y(discard_pts:end, :);
T_plot = T(discard_pts:end);
x = Y_plot(:,1); y = Y_plot(:,2); z = Y_plot(:,3);


figure('Color', 'w', 'Name', 'Time Series Analysis', 'Position', [100, 100, 800, 600]);
tlo1 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'loose');


ax1 = nexttile; plot(T_plot, x, 'Color', '#0072BD', 'LineWidth', 1);

ylabel('$x(t)$', 'Interpreter', 'latex', 'Rotation', 0); grid on; axis padded;

text(ax1, 1.02, 0.5, '(a)', 'Units', 'normalized', ...
    'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman', ...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');


ax2 = nexttile; plot(T_plot, y, 'Color', '#D95319', 'LineWidth', 1);
ylabel('$y(t)$', 'Interpreter', 'latex', 'Rotation', 0); grid on; axis padded;

text(ax2, 1.02, 0.5, '(b)', 'Units', 'normalized', ...
    'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman', ...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');


ax3 = nexttile; plot(T_plot, z, 'Color', '#77AC30', 'LineWidth', 1);
ylabel('$\phi(t)$', 'Interpreter', 'latex', 'Rotation', 0); xlabel('Time (s)'); grid on; axis padded;

text(ax3, 1.02, 0.5, '(c)', 'Units', 'normalized', ...
    'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman', ...
    'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

set([ax1, ax2, ax3], 'TickLabelInterpreter', 'latex', 'Box', 'on', 'FontSize', 11);


figure('Color', 'w', 'Name', 'Phase Portraits', 'Position', [150, 150, 900, 750]);
tlo2 = tiledlayout(2, 2, 'TileSpacing', 'normal', 'Padding', 'compact');


ax_xy = nexttile; plot(x, y, 'Color', '#0072BD', 'LineWidth', 0.8);
xlabel('$x$', 'Interpreter', 'latex'); ylabel('$y$', 'Interpreter', 'latex', 'Rotation', 0);
title('(a)'); grid on; axis padded; 
set(ax_xy, 'YDir', 'reverse'); 


ax_xz = nexttile; plot(x, z, 'Color', '#D95319', 'LineWidth', 0.8);
xlabel('$x$', 'Interpreter', 'latex'); ylabel('$\phi$', 'Interpreter', 'latex', 'Rotation', 0);
title('(b)'); grid on; axis padded;


ax_yz = nexttile; plot(y, z, 'Color', '#7E2F8E', 'LineWidth', 0.8);
xlabel('$y$', 'Interpreter', 'latex'); ylabel('$\phi$', 'Interpreter', 'latex', 'Rotation', 0);
title('(c)'); grid on; axis padded;
set(ax_yz, 'XDir', 'reverse'); 


ax_3d = nexttile; plot3(x, y, z, 'Color', '#77AC30', 'LineWidth', 0.6); 
xlabel('$x$', 'Interpreter', 'latex'); ylabel('$y$', 'Interpreter', 'latex'); 
zlabel('$\phi$', 'Interpreter', 'latex', 'Rotation', 0);
title('(d)'); grid on; view(135, 25); axis padded;



all_axes = findobj(gcf, 'type', 'axes');
set(all_axes, 'TickLabelInterpreter', 'latex', 'Box', 'on', 'FontSize', 12);

