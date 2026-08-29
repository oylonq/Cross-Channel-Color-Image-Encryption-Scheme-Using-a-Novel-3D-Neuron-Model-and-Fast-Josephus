function dX = sys_ext_flow(t, X, a, b, c, d, I, k, MT)
    
    x = X(1); y = X(2); phi = X(3);
    
   
    
    
    Y = [X(4), X(7), X(10);
         X(5), X(8), X(11);
         X(6), X(9), X(12)];
    
    dX = zeros(12, 1);
    
    
    dX(1) = y - a*x^3 + b*x^2 + I - k*phi*x;
    dX(2) = c - d*x^2 - y;
    dX(3) = k*(1 - x / MT)*phi*(1-phi);
    
    Jac = [-3*a*x^2 + 2*b*x - k*phi,  1,                     -k*x;
           -2*d*x,                   -1,                        0;
            -k*phi*(1-phi)/MT,        0,     k*(1-x/MT)*(1 - 2*phi)];
    
    
    dY = Jac * Y; 
    dX(4:12) = dY(:); 
end

