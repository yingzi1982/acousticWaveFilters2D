#!/usr/bin/env octave

clear all
close all
clc

[xmin xmax nx dx x zmin zmax nz dz z dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters;
%---------------------------------

arg_list = argv ();
if length(arg_list) > 0
  piezoelectricEffect = arg_list{1};
else
  piezoelectricEffect = input('Please input direct or converse piezoelectric effect ','s');
end

switch piezoelectricEffect
case 'direct'
%
case 'converse'
electricFields=dlmread('../backup/electricFields');
%Ex = reshape(electricFields(:,[6]),nz,nx);
%Ez = reshape(electricFields(:,[7]),nz,nx);
Ex = electricFields(:,[6]);
Ey = zeros(size(Ex));
Ez = electricFields(:,[7]);
E = [Ex Ey Ez];
E = transpose(E);
otherwise
disp(['Plesse input direct/converse!'])
end

stress = -transpose(piezoelectric_constant)*E;
whos stress
