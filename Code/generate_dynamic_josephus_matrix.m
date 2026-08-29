function [josephus_matrix] = generate_dynamic_josephus_matrix(M, N, Z, start, space, chaotic_matrix_for_loop_maintaince)
% params

for k = 1:Z
  orig_sequence = 1:M*N;
  josephus_sequence = orig_sequence;
  len = length(orig_sequence);

  for i = 1:M*N
    pos = start(k) + space(k,i) - 1; % 取模前减一，取模后加一，避免下标越界
    pos = mod(pos - 1, len);
    pos = pos + 1;

    josephus_sequence(i) = orig_sequence(pos);
    if chaotic_matrix_for_loop_maintaince(k, i) < 1
      orig_sequence(pos) = orig_sequence(1);
      orig_sequence(1) = orig_sequence(len);
    else
      orig_sequence(pos) = orig_sequence(len);
    end
    len = len - 1;

    start(k) = pos;
  end

  josephus_matrix(:,:,k) = reshape(josephus_sequence,[M,N]);
end

end
% function [josephus_matrix] = dynamic_josephus_matrix_generator(M, N, Z, start, space)
%     % params
%
%     for k = 1:Z
%         orig_sequence = 1:M*N;
%         josephus_sequence = orig_sequence;
%
%         for i = 1:M*N
%             len = length(orig_sequence);
%             pos = start(k) + space(k,i) - 1; % 取模前减一，取模后加一，避免下标越界
%             pos = mod(pos - 1, len);
%             pos = pos + 1;
%
%             josephus_sequence(i) = orig_sequence(pos);
%             orig_sequence(pos) = [];
%
%             start(k) = pos;
%         end
%
%         josephus_matrix(:,:,k) = reshape(josephus_sequence,[M,N]);
%     end
%
% end
