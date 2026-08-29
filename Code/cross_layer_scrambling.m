function [permuted_image] = cross_layer_scrambling(image, josephus_matrix, cross_layer_matrix)
    % params
    % image: ;josephus_matrix: ;cross_layer_matrix: ;
    
    % Making a empty matrix to store results
    [M,N,Z] = size(image);
    permuted_image = zeros(M,N,Z);

    for k = 1:Z
        for i = 1:M
            for j = 1:N

                % Getting the corresponding position
                pos_val = josephus_matrix(i, j, k);
                pos_i = floor((pos_val - 1) / N) + 1; % we need to handle the first element and the last enlemet
                pos_j = mod(pos_val - 1, N) + 1;
                pos_k = k;

                % Getting the corresponding layer
                pixel_layer = cross_layer_matrix(pos_i, pos_j, pos_k);
                
                % Obtain the corresponding pixel
                pixel = image(pos_i, pos_j, pixel_layer);

                % Put the pixel into the corresponding position
                permuted_image(i, j, k) = pixel;
                
            end
            
        end
        
    end
    
    
end
