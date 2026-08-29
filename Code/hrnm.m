% function dYdt = hrnm(t, Y, a, b, a1, b1, k, s, phi, epsilon)
% 
% x = Y(1);
% y = Y(2);
% z = Y(3);
% 
% dxdt = -s*(-a*x^3 + x^2) - y - b*z;
% dydt = phi*(x^2 - y);
% dzdt = epsilon*(s*a1*x + b1 - k*z);
% 
% dYdt =  [dxdt; dydt; dzdt];
% end
% --- 系统方程 ---
function f = hrnm(t, X, a, b, c, d, I, k, MT)
    x = X(1); y = X(2); phi = X(3);
    f = zeros(3,1);
    f(1) = y - a*x^3 + b*x^2 + I - k*phi*x;
    f(2) = c - d*x^2 - y;
    f(3) = k*(1 - x / MT)*phi*(1-phi);
end