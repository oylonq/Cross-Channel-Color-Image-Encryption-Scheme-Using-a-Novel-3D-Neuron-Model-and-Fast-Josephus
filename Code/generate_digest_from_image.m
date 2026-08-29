function digest = generate_digest_from_image(image, hash_method)
% generate_digest_from_image 使用 Java Bridge 计算图像文件的哈希值

image = reshape(image,1,[]);

% --- 使用 Java MessageDigest 计算哈希值 ---
try
  % 获取 SHA-256 实例
  %message_digest = java.security.MessageDigest.getInstance('SHA-256');
  message_digest = java.security.MessageDigest.getInstance(hash_method);


  % 更新哈希摘要 (将 MATLAB uint8 数组传递给 Java)
  message_digest.update(image);

  % 计算最终哈希值 (Java byte array)
  digest_bytes = message_digest.digest();

  % 转换为 MATLAB uint8 数组
  digest = typecast(digest_bytes, 'uint8');

catch Error
  error('哈希计算失败: %s', Error.message);
end
end
