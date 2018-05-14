%% linear algorithm, bilinear interpolation
% A Rostov 23/04/2018
%%
function lin_1st = interp_linear_1st(input_image)
[Nx, Ny] = size(input_image);
%%  take out all three layers
% Iprobe = inimg;
I   = double(input_image);
Ir  = zeros(Nx, Ny, 3);
IRr = double(Ir(:,:,1));
IGr = double(Ir(:,:,2));
IBr = double(Ir(:,:,3));

% IRrprobe = Iprobe(:,:,1);
% IGrprobe = Iprobe(:,:,2);
% IBrprobe = Iprobe(:,:,3);



%% calculate red layer
for i = 2 : floor(Nx/2)*2
    for j = 1 : Ny - 1
        if(mod(i, 2) == 0) % четные строки
            if(mod(j, 2) == 0)
              Ir(i, j, 1) = round((I(i, j - 1) + I(i, j + 1))/2);
            else
              Ir(i, j, 1) =  I(i, j);
            end
        else % нечетные строки
            if(mod(j, 2) == 0)
              Ir(i, j, 1) = round((I(i - 1, j - 1) + I(i + 1, j - 1) + I(i - 1, j + 1) + I(i + 1, j + 1))/4);   
            else
              Ir(i, j, 1) = round((I(i - 1, j) + I(i + 1, j))/2);   
            end
        end
    end
end
IRRr = (Ir(:,:,1));
%% calculate blue layer
for i = 1 : Nx - 1
    for j = 2 : floor(Ny/2)*2
        if(mod(i, 2) == 0) % четные строки
            if(mod(j, 2) == 0)              
              Ir(i, j, 3) = round((I(i - 1, j) + I(i + 1, j))/2);   
            else
              Ir(i, j, 3) = round((I(i - 1, j - 1) + I(i + 1, j - 1) + I(i - 1, j + 1) + I(i + 1, j + 1))/4);   
            end
        else % нечетные строки
            if(mod(j, 2) ~= 0)
              Ir(i, j, 3) = round((I(i, j - 1) + I(i, j + 1))/2);  
            else
              Ir(i, j, 3) = I(i, j);  
            end             
        end
    end
end

%% calculate green layer
for i = 2 : floor(Nx/2)*2 - 1
    for j = 2 : floor(Ny/2)*2 - 1
        if(mod(i, 2) == 0) % четные строки
            if(mod(j, 2) ~= 0)              
              Ir(i, j, 2) = round((I(i, j - 1) + I(i, j + 1) + I(i - 1, j) + I(i + 1, j))/4);  
            else
              Ir(i, j, 2) =  I(i, j);  
            end
        else % нечетные строки
            if(mod(j, 2) == 0)
              Ir(i, j, 2) = round((I(i, j - 1) + I(i, j + 1) + I(i - 1, j) + I(i + 1, j))/4);   
            else
              Ir(i, j, 2) =  I(i, j);
            end             
        end
    end
end

lin_1st = uint8(Ir);

end