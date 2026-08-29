function [diffused_image] = josephus_diffusion(permuted_image, josephus_diffusion_matrix, chaotic_diffusion_matrix, M, N, Z)
  % params
 
  diffused_image = zeros(M, N, Z);
  pre_xored_pixel = uint8(0);

  for k = 1 : Z
    for i = 1 : M
      for j = 1 : N
        pos_val = josephus_diffusion_matrix(i, j, k);
        pos_k = floor((pos_val - 1) / (M*N)) + 1;

        pos_val = mod(pos_val - 1, M*N) + 1;
        pos_i = floor((pos_val - 1) / N) + 1; % we need to handle the first element and the last enlemet
        pos_j = mod(pos_val - 1, N) + 1;
        

        xored_pixel = bitxor(bitxor(permuted_image(pos_i, pos_j, pos_k), pre_xored_pixel), chaotic_diffusion_matrix(pos_i, pos_j, pos_k));
        diffused_image(i, j, k) = xored_pixel;
        pre_xored_pixel = xored_pixel;

      end

    end

  end

end
