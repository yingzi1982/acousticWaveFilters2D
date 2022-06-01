#!/usr/bin/env octave

clear all
close all
clc

[xmin xmax nx dx x zmin zmax nz dz z dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters;
elastic_constant
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
E_x = reshape(electricFields(:,[6]),nz,nx);
E_z = reshape(electricFields(:,[7]),nz,nx);
otherwise
disp(['Plesse input direct/converse!'])
end
