function [cross_layer_matrix] = generate_cross_layer_matrix(cross_layer_chaotic_sequence, M, N, Z)
cross_layer_matrix = reshape(cross_layer_chaotic_sequence, [M, N, Z]);

for i = 1 : M
  for j = 1 : N

    [~, cross_layer_matrix(i, j, :)] = sort(cross_layer_matrix(i, j, :));

  end

end

end
