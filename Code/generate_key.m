function [In_Key] = generate_key(PI, Ex_Key, scale_factor)
tic;

% 密钥生成
image_sha512_digest = generate_digest_from_image(PI, "SHA-512");
binary_32bit_strings = reshape(dec2bin(image_sha512_digest), [], 32);
decimal_32bit_values = bin2dec(binary_32bit_strings);

perturbation_vector = zeros(1, 6);
decimal_blocks = length(decimal_32bit_values); % 原始数据块的数量

for i = 1:6
  % 逻辑：每个 perturbation_vector(i) 由 idx1, idx2, idx3 三个位置的值异或而成
  idx1 = i;
  idx2 = mod(i + 6 - 1, decimal_blocks) + 1; % 相当于原来的 i+6
  idx3 = mod(i + 12 - 1, decimal_blocks) + 1; % 相当于原来的 i+12

  % 执行连续异或
  perturbation_vector(i) = bitxor(bitxor(decimal_32bit_values(idx1), ...
    decimal_32bit_values(idx2)), ...
    decimal_32bit_values(idx3));
end

perturbation_vector = mod(perturbation_vector / 2^32, 1);

% --- 生成最终关联明文的混沌初值 (Perturbed Keys) ---
% 将外部密钥与基于图像生成的扰动量融合，实现“一图一密”
In_Key = mod(Ex_Key + scale_factor * perturbation_vector, 1);
% x1 = mod(x0 + scale_factor * perturbation_vector(1), 1);
% y1 = mod(y0 + scale_factor * perturbation_vector(2), 1);
% z1 = mod(z0 + scale_factor * perturbation_vector(3), 1);
% u1 = mod(u0 + scale_factor * perturbation_vector(4), 1);
% v1 = mod(v0 + scale_factor * perturbation_vector(5), 1);
% w1 = mod(w0 + scale_factor * perturbation_vector(6), 1);

t = toc;
fprintf('密钥生成运行耗时：%.4f 秒\n', t);
end
