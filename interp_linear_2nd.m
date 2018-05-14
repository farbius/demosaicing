%% linear algorithm with vertical and horizontal gradient
% A Rostov 25/04/2018
%%
function lin_2nd = interp_linear_2nd(input_image, GL)
[Nx, Ny] = size(input_image);
%%  take out all three layers
% Iprobe = inimg;
I   = double(input_image);
Ir  = zeros(Nx, Ny, 3);
r = 1;
g = 2;
b = 3;
  IRr = double(Ir(:,:,1));
  IGr = double(Ir(:,:,2));
  IBr = double(Ir(:,:,3));
  GL = GL;

% IRrprobe = Iprobe(:,:,1);
% IGrprobe = Iprobe(:,:,2);
% IBrprobe = Iprobe(:,:,3);
deltaH = 0;
deltaV = 0;

%% calculate G for red and blue layers
for i = 2 : floor(Nx/2)*2 - 2
    for j = 2 : floor(Ny/2)*2 - 2
        if(mod(i, 2) == 0) % четные строки
          
            if(mod(j, 2) ~= 0)
            
                    if(i == 2)

                      deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j - 2)) + abs(I(i, j) - I(i, j + 2));
                      deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/8);                    
                        end

                    elseif(j == 2)


                       deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j)) + abs(I(i, j) - I(i, j + 2));
                       deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i - 2, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/8);                    
                        end  

                    elseif(i == 2 && j == 2)


                       deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j)) + abs(I(i, j) - I(i, j + 2));
                       deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/8);                    
                        end  


                    else

                       deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j - 2)) + abs(I(i, j) - I(i, j + 2));
                       deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i - 2, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/8);                    
                        end
                   
                    end
            else
                Ir(i, j, g) = I(i, j);
            end % нечетные столбцы      
        else % нечетные строки
            
             if(mod(j, 2) == 0)
                         
                    if(j == 2)


                       deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j)) + abs(I(i, j) - I(i, j + 2));
                       deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i - 2, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j) + I(i, j) - I(i, j + 2))/8);                    
                        end                     

                    else

                       deltaH = abs(I(i, j - 1) - I(i, j + 1)) + abs(I(i, j) - I(i, j - 2)) + abs(I(i, j) - I(i, j + 2));
                       deltaV = abs(I(i - 1, j) - I(i + 1, j)) + abs(I(i, j) - I(i - 2, j)) + abs(I(i, j) - I(i + 2, j));
                        if deltaH < deltaV
                             Ir(i, j, g) = floor((I(i, j - 1) + I(i, j + 1))/2 + (I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/4);
                        elseif deltaH > deltaV
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j))/2 + (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j))/4);                    
                        else
                             Ir(i, j, g) = floor((I(i - 1, j) + I(i + 1, j) + I(i, j - 1) + I(i, j + 1))/4 + ...
                                 (I(i, j) - I(i - 2, j) + I(i, j) - I(i + 2, j) + I(i, j) - I(i, j - 2) + I(i, j) - I(i, j + 2))/8);                    
                        end  

                    end
             else
                 Ir(i, j, g) = I(i, j);
            end % четные столбцы                            
            
        end
    end
end
IRRr = (Ir(:,:,g));
%% calculate red layer

deltaNeg = 0;
deltaPos = 0;

for i = 2 : floor(Nx/2)*2 - 1
    for j = 2 : floor(Ny/2)*2 - 1
        if(mod(i, 2) == 0) % четные строки
            
            
            if(mod(j, 2) == 0)              
              Ir(i, j, r) = round((I(i, j - 1) + I(i, j + 1))/2 + (Ir(i, j, g) - Ir(i, j - 1, g) + Ir(i, j, g) - Ir(i, j + 1, g))/4);   
            else
              Ir(i, j, r) = I(i, j);
            end
            
            
        else % нечетные строки
            
            if(mod(j, 2) == 0)
                
              deltaNeg = abs(I(i - 1, j - 1) + I(i + 1, j + 1)) + abs(Ir(i, j, g) - Ir(i - 1, j - 1, g)) + abs(Ir(i, j, g) - Ir(i + 1, j + 1, g));
              deltaPos = abs(I(i - 1, j + 1) + I(i + 1, j - 1)) + abs(Ir(i, j, g) - Ir(i - 1, j + 1, g)) + abs(Ir(i, j, g) - Ir(i + 1, j - 1, g));
              if(deltaNeg < deltaPos)
                     Ir(i, j, r) = round((I(i - 1, j - 1) + I(i + 1, j + 1))/2 + (2*Ir(i, j, g) - Ir(i - 1, j - 1, g) - Ir(i + 1, j + 1, g))/4); 
              elseif(deltaNeg > deltaPos)
                     Ir(i, j, r) = round((I(i - 1, j + 1) + I(i + 1, j - 1))/2 + (2*Ir(i, j, g) - Ir(i - 1, j + 1, g) - Ir(i + 1, j - 1, g))/4); 
              else
                     Ir(i, j, r) = round((I(i - 1, j - 1) + I(i + 1, j + 1) + I(i - 1, j + 1) + I(i + 1, j - 1))/4 + ...
                      (4*Ir(i, j, g) - Ir(i - 1, j - 1, g) - Ir(i + 1, j + 1, g)- Ir(i - 1, j + 1, g) - Ir(i + 1, j - 1, g))/8); 
              end
              
            else
                
              Ir(i, j, r) = round((I(i - 1, j) + I(i + 1, j))/2 + (Ir(i, j, g) - Ir(i - 1, j, g) + Ir(i, j, g) - Ir(i + 1, j, g))/4);     
            
            end      
            
        end
    end
end

%% calculate blue layer

for i = 2 : floor(Nx/2)*2 - 1
    for j = 2 : floor(Ny/2)*2 - 1
        if(mod(i, 2) == 0) % четные строки
        
            if(mod(j, 2) == 0)
                
              Ir(i, j, b) = round((I(i - 1, j) + I(i + 1, j))/2 + (Ir(i, j, g) - Ir(i - 1, j, g) + Ir(i, j, g) - Ir(i + 1, j, g))/4);     
              
              
            else
                
              deltaNeg = abs(I(i - 1, j - 1) + I(i + 1, j + 1)) + abs(Ir(i, j, g) - Ir(i - 1, j - 1, g)) + abs(Ir(i, j, g) - Ir(i + 1, j + 1, g));
              deltaPos = abs(I(i - 1, j + 1) + I(i + 1, j - 1)) + abs(Ir(i, j, g) - Ir(i - 1, j + 1, g)) + abs(Ir(i, j, g) - Ir(i + 1, j - 1, g));
              if(deltaNeg < deltaPos)
                     Ir(i, j, b) = round((I(i - 1, j - 1) + I(i + 1, j + 1))/2 + (2*Ir(i, j, g) - Ir(i - 1, j - 1, g) - Ir(i + 1, j + 1, g))/4); 
              elseif(deltaNeg > deltaPos)
                     Ir(i, j, b) = round((I(i - 1, j + 1) + I(i + 1, j - 1))/2 + (2*Ir(i, j, g) - Ir(i - 1, j + 1, g) - Ir(i + 1, j - 1, g))/4); 
              else
                     Ir(i, j, b) = round((I(i - 1, j - 1) + I(i + 1, j + 1) + I(i - 1, j + 1) + I(i + 1, j - 1))/4 + ...
                      (4*Ir(i, j, g) - Ir(i - 1, j - 1, g) - Ir(i + 1, j + 1, g)- Ir(i - 1, j + 1, g) - Ir(i + 1, j - 1, g))/8); 
              end
                          
            end                
            
            
        else % нечетные строки
            
              
            if(mod(j, 2) ~= 0)              
              Ir(i, j, b) = round((I(i, j - 1) + I(i, j + 1))/2 + (Ir(i, j, g) - Ir(i, j - 1, g) + Ir(i, j, g) - Ir(i, j + 1, g))/4);   
            else
              Ir(i, j, b) = I(i, j);
            end
                 
            
        end
    end
end

lin_2nd = uint8(Ir);

end