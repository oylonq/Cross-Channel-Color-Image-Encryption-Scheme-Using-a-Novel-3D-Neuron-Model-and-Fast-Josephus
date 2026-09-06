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
 % function In_Key = generate_key(PI, Ex_Key, scale_factor)
 %      % 强制 Ex_Key 为行向量，并校验长度
 %      Ex_Key = Ex_Key(:)';
 % 
 %      if length(Ex_Key) ~= 3
 %          error('Ex_Key must be a 3-element vector for the 3D MHR model.');
 %      end
 % 
 %      if scale_factor <= 0
 %          error('scale_factor must be positive.');
 %      end
 % 
 %      % 计算 SHA-512 摘要，并强制转换为 64 字节
 %      image_sha512_digest = generate_digest_from_image(PI, 'SHA-512');
 %      image_sha512_digest = uint8(image_sha512_digest(:));
 % 
 %      if length(image_sha512_digest) ~= 64
 %          error('SHA-512 digest must be 64 bytes.');
 %      end
 % 
 %      % 标准方式：64 字节 -> 16 个 uint32
 %      decimal_32bit_values = typecast(image_sha512_digest, 'uint32');
 % 
 %      % 生成 3 维扰动向量
 %      % 从 16 个 32-bit 块中选 3 组，每组用 3 个不同位置异或，保证熵的充分利用
 %      idx1 = 1:3;
 %      idx2 = mod(idx1 + 5, 16) + 1;   % 偏移 5
 %      idx3 = mod(idx1 + 10, 16) + 1;  % 偏移 10
 % 
 %      perturbation_vector = bitxor(bitxor(decimal_32bit_values(idx1), ...
 %                                          decimal_32bit_values(idx2)), ...
 %                                          decimal_32bit_values(idx3));
 % 
 %      % 归一化到 [0, 1)
 %      perturbation_vector = perturbation_vector / 2^32;
 % 
 %      % 融合外部密钥与扰动，得到最终 MHR 初值 [x1, y1, phi1]
 %      In_Key = mod(Ex_Key + scale_factor * perturbation_vector, 1);
 %  end