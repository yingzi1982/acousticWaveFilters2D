#!/usr/bin/env octave

clear all
close all
clc


%model_number 1 rho Vp Vs 0 0 QKappa Qmu 0 0 0 0 0 0

sound_speed_in_water = [1450:0.1:1550]';

water     = [ones(size(sound_speed_in_water)) 1030*ones(size(sound_speed_in_water)) sound_speed_in_water     0.0*ones(size(sound_speed_in_water))  zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) 9999*ones(size(sound_speed_in_water)) 9999*ones(size(sound_speed_in_water))  zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) zeros(size(sound_speed_in_water)) ];
%---------------------------
%water    =    [1   1000.0  1500.0  0.00   0 0 9999 9999 0 0 0 0 0 0];
%---------------------------

%case_1
%solid_1     = [1 2020 1980  1300 0 0   60    45  0 0 0 0 0 0];
%solid_2     = [1 2275 2650  1600 0 0  160   120  0 0 0 0 0 0];
%solid_3     = [1 2510 4300  2500 0 0  200   150  0 0 0 0 0 0];
%case_2
solid_1     = [1 2120 1980  1300 0 0   60    45 0 0 0 0 0 0];
solid_2     = [1 2475 2650  1600 0 0  160   120 0 0 0 0 0 0];
solid_3     = [1 2660 4300  2500 0 0  200   150  0 0 0 0 0 0];
%case_3
%solid_1     = [1 2120 1980  1300 0 0   40    30 0 0 0 0 0 0];
%solid_2     = [1 2475 2650  1600 0 0  180   135 0 0 0 0 0 0];
%solid_3     = [1 2660 4300  2500 0 0  240   180  0 0 0 0 0 0];

solid = [solid_1;solid_2;solid_3];
%solid = [solid_1;solid_2];
solid_pml = solid;
solid_pml(:,[7 8]) = 9999;
materials = [solid;solid_pml;water];

nbmodels = rows(materials);
models = [[1:nbmodels]' materials];


fileID = fopen(['../backup/nbmodels'],'w');
fprintf(fileID, '\n')
fprintf(fileID, '#------------------------------------------------------------\n')
fprintf(fileID, 'nbmodels                        = %i\n',nbmodels)
fprintf(fileID, '#------------------------------------------------------------\n')
fprintf(fileID, '\n')
fclose(fileID);
%-------------------------------------------------------------------------------------

fileID = fopen(['../backup/models'],'w');
for nmodel = [1:nbmodels]
  fprintf(fileID, '%i %i %f %f %f %i %i %f %f %i %i %i %i %i %i \n', ...
  models(nmodel,1),  models(nmodel,2),  models(nmodel,3),  models(nmodel,4),  models(nmodel,5),...
  models(nmodel,6),  models(nmodel,7),  models(nmodel,8),  models(nmodel,9),  models(nmodel,10),...
  models(nmodel,11), models(nmodel,12), models(nmodel,13), models(nmodel,14), models(nmodel,15))
end       
fprintf(fileID, '\n')
fclose(fileID);
