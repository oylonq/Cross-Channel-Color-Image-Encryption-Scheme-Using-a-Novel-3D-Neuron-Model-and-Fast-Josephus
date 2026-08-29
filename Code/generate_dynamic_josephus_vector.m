function [josephus_vector] = generate_dynamic_josephus_vector(M, N, Z, start, space, chaotic_sequence_for_loop_maintaince)
% params

orig_vector = 1:M*N*Z;
josephus_vector = orig_vector;
len = length(orig_vector);

for i = 1:M*N*Z
  pos = start + space(i) - 1; % 取模前减一，取模后加一，避免下标越界
  pos = mod(pos - 1, len) + 1;

  josephus_vector(i) = orig_vector(pos);

  if chaotic_sequence_for_loop_maintaince(i) < 1
    orig_vector(pos) = orig_vector(1);
    orig_vector(1) = orig_vector(len);
  else
    orig_vector(pos) = orig_vector(len);
  end
  len = len - 1;

  start = pos;
end

end
