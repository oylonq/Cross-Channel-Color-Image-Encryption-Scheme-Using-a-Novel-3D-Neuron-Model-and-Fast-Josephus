function validate_complexity()
%VALIDATE_COMPLEXITY  Experimentally validate the O(L) encryption complexity.
%   Measures total encryption time (key generation + encryption) and pure
%   encryption time for square RGB images of increasing size.  Saves a table,
%   a MAT file, and a PDF plot in the current directory.

    clc;

    % Experimental parameters
    sizes      = [128, 256, 512, 1024];   % square spatial dimension M = N
    num_reps   = 3;                        % repetitions per size for stability
    Ex_key     = [1, -1, 0.1, 1.5, -1.5, 0.2];
    scale_factor = 0.2;

    rng(42, 'twister');                    % reproducible random images

    M_vec          = zeros(numel(sizes), 1);
    L_vec          = zeros(numel(sizes), 1);
    total_time_mean = zeros(numel(sizes), 1);
    total_time_std  = zeros(numel(sizes), 1);
    enc_time_mean   = zeros(numel(sizes), 1);
    enc_time_std    = zeros(numel(sizes), 1);

    fprintf('Running complexity validation ...\n');
    fprintf('%-6s %-12s %-16s %-16s %-16s %-16s\n', ...
            'M','L','TotalMean(s)','TotalStd(s)','EncMean(s)','EncStd(s)');

    for k = 1:numel(sizes)
        M = sizes(k);
        N = M;
        Z = 3;
        L = M * N * Z;

        total_times = zeros(num_reps, 1);
        enc_times   = zeros(num_reps, 1);

        for r = 1:num_reps
            % Random RGB image (any image content is valid for timing)
            PI = randi([0, 255], M, N, Z, 'uint8');

            % Total time: key generation + encryption
            t0 = tic;
            In_Key = generate_key(PI, Ex_key, scale_factor);
            CI     = encryption(PI, In_Key);
            total_times(r) = toc(t0);

            % Pure encryption time (excludes SHA-512 key generation)
            t1 = tic;
            CI = encryption(PI, In_Key);
            enc_times(r) = toc(t1);
        end

        M_vec(k)          = M;
        L_vec(k)          = L;
        total_time_mean(k) = mean(total_times);
        total_time_std(k)  = std(total_times);
        enc_time_mean(k)   = mean(enc_times);
        enc_time_std(k)    = std(enc_times);

        fprintf('%-6d %-12d %-16.4f %-16.4f %-16.4f %-16.4f\n', ...
                M, L, total_time_mean(k), total_time_std(k), enc_time_mean(k), enc_time_std(k));
    end

    results = table(M_vec, L_vec, total_time_mean, total_time_std, enc_time_mean, enc_time_std, ...
                    'VariableNames', {'M','L','TotalTime_mean','TotalTime_std','EncTime_mean','EncTime_std'});

    % Linear fit of total time versus L
    p  = polyfit(results.L, results.TotalTime_mean, 1);
    fit_time = polyval(p, results.L);
    ss_res = sum((results.TotalTime_mean - fit_time).^2);
    ss_tot = sum((results.TotalTime_mean - mean(results.TotalTime_mean)).^2);
    R2 = 1 - ss_res / ss_tot;

    fprintf('\nLinear fit T_total = %.6e * L + %.6f, R^2 = %.4f\n', p(1), p(2), R2);

    % Save numerical results
    writetable(results, 'complexity_validation.txt', 'Delimiter', '\t');
    save('complexity_validation.mat', 'results', 'p', 'R2');

    % Plot
    figure('Visible', 'on');
    errorbar(results.L / 1e6, results.TotalTime_mean, results.TotalTime_std, ...
             'o-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
    hold on;
    plot(results.L / 1e6, fit_time, '--r', 'LineWidth', 1.5);
    xlabel('Number of components $L$ (millions)', 'Interpreter', 'latex');
    ylabel('Total encryption time (s)', 'Interpreter', 'latex');
    title('Experimental validation of linear $O(L)$ complexity', 'Interpreter', 'latex');
    legend('Measured time (mean $\pm$ std)', sprintf('Linear fit ($R^2=%.4f$)', R2), ...
           'Location', 'northwest', 'Interpreter', 'latex');
    grid on;
    set(gca, 'FontSize', 12);
    print('complexity_validation', '-dpdf', '-r300');

    fprintf('Saved complexity_validation.txt, .mat, and .pdf\n');
end
