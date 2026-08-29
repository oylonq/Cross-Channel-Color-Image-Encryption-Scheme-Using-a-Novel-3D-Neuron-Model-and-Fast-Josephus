function [de_permuted_image] = de_cross_layer_scrambling(permuted_image, josephus_matrix, cross_layer_matrix)
    % params
    % permuted_image:  , josephus_matrix:  , cross_layer_matrix:  
    
    % Making a empty matrix to store results
    [M,N,Z] = size(permuted_image);
    de_permuted_image = zeros(M,N,Z);

    for k = 1:Z
        for i = 1:M
            for j = 1:N

                % Getting the corresponding pixel
                pixel = permuted_image(i, j, k);

                % Calculating the corresponding position by josephus_matrix
                pos_val = josephus_matrix(i, j, k);
                pos_i = floor((pos_val-1) / N) + 1;
                pos_j = mod(pos_val-1, N) + 1;
                pos_k = k;

                % Getting the corresponding layer by cross_layer_matrix
                pixel_layer = cross_layer_matrix(pos_i, pos_j, pos_k);
                
                % Putting the pixel into the corresponding position
                de_permuted_image(pos_i, pos_j, pixel_layer) = pixel;

            end
            
        end
        
    end
    
    
end
