%% demosaic algorithm
% A Rostov 07/05/2018
% a.rostov@riftek.com
%%
clc
clear 
% исходный файл
fileID = -1;
errmsg = '';
while fileID < 0 
   disp(errmsg);
   filename = input('Open file: ', 's');
   [fileID,errmsg] = fopen(filename);
   I = imread(filename);
end
[Nx, Ny, Nz] = size(I);

%% mask for G
Zo1O = zeros(Nx, Ny);
for i = 1 : Nx
    for j = 1 : Ny
        if(mod(i, 2) == 0)
            if(mod(j, 2) == 0)
              Zo1O(i, j) = 1;  
            else
              Zo1O(i, j) = 0;   
            end
        else
            if(mod(j, 2) == 0)
              Zo1O(i, j) = 0;  
            else
              Zo1O(i, j) = 1;   
            end
        end
    end
end
maskG = (Zo1O);
%% mask for R
Zo2O = zeros(Nx, Ny);
for i = 1 : Nx
    for j = 1 : Ny
        if(mod(i, 2) == 0)
            if(mod(j, 2) == 0)
              Zo2O(i, j) = 0;  
            else
              Zo2O(i, j) = 1;   
            end
        end
    end
end
maskB = (Zo2O);
%% mask for B
Zo3O = zeros(Nx, Ny);
for i = 1 : Nx
    for j = 1 : Ny
        if(mod(i, 2) ~= 0)
            if(mod(j, 2) == 0)
              Zo3O(i, j) = 1;  
            else
              Zo3O(i, j) = 0;   
            end
        end
    end
end
maskR = (Zo3O);

%% Bayer filter output
Iout = I;
Iout(:, :, 1) = uint8(double(Iout(:, :, 1)).*maskR);
Iout(:, :, 2) = uint8(double(Iout(:, :, 2)).*maskG);
Iout(:, :, 3) = uint8(double(Iout(:, :, 3)).*maskB);

IoutByte = zeros(Nx, Ny);

IoutByte = Iout(:, :, 1) + Iout(:, :, 2) + Iout(:, :, 3);

% 
fid = fopen('BayerData.txt', 'w');
display('Writing data for RTL model...');
for i = 1 : Nx
    for j = 1 : Ny
      fprintf(fid, '%x\n', IoutByte(i, j));  
    end
end
fclose(fid);

%%
fid = fopen('parameter.vh', 'w');
fprintf(fid,'parameter Nrows   = %d ;\n', Ny);
fprintf(fid,'parameter Ncol    = %d ;\n', Nx);
fclose(fid);
display('Please, start write_prj.tcl');
prompt = 'Press Enter when RTL modeling is done \n';
x = input(prompt);

%% read processing data
fidR = fopen(fullfile([pwd '\demosaicing.sim\sim_1\behav\xsim'],'Rs_out.txt'), 'r');
fidG = fopen(fullfile([pwd '\demosaicing.sim\sim_1\behav\xsim'],'Gs_out.txt'), 'r');
fidB = fopen(fullfile([pwd '\demosaicing.sim\sim_1\behav\xsim'],'Bs_out.txt'), 'r');
R = zeros(1, Nx*Ny);
G = zeros(1, Nx*Ny);
B = zeros(1, Nx*Ny);
  R = fscanf(fidR,'%d');  
  G = fscanf(fidG,'%d');  
  B = fscanf(fidB,'%d');  
fclose(fidR);
fclose(fidG);
fclose(fidB);

Iprocess = zeros(Nx, Ny, 3);
n = 1;
for i = 1 : Nx - 1
    for j = 1 : Ny 
       Iprocess(i, j, 1) = R(n); 
       Iprocess(i, j, 2) = G(n); 
       Iprocess(i, j, 3) = B(n); 
       n = n + 1;
 end
end

Iprocess = uint8(Iprocess);
%% algorithm
lin_1st = interp_linear_1st(IoutByte);
%lin_2nd = interp_linear_2nd(IoutByte);
%% graphics
figure(1)
imshow(I);
title('Исходное изображение')

figure(2)
imshow(IoutByte);
title('Выход фильтра Байера')

figure(3)
imshow(lin_1st);
title('Работа алгоритма в Matlab')

figure(4)
imshow(Iprocess);
title('Работа алгоритма в RTL модели')
display('processing done!');

% figure(5)
% imshow(lin_2nd);
% title('Работа 2 - го алгоритма в Matlab')






