function [x_next] = logistic_map(mu, x_n)
    x_next = mu * x_n * (1 - x_n); % mu (3.87,4]
    
end