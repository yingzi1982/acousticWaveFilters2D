#!/usr/bin/env octave

clear all
close all
clc

[xmin xmax zmin zmax step dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters;
dx = step;
dz = step;
nx = round((xmax-xmin)/dx+1);
nz = round((zmax-zmin)/dz+1);

ymin = 0;
ymax = 0;
ny = 1;
dy = step;

x = linspace(xmin,xmax,nx);
y = linspace(ymin,ymax,ny);
z = linspace(zmin,zmax,nz);
[X Y Z] = meshgrid (x,y,z);
whos X Y Z
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

stress1 = reshape(stress(1,:),nz,nx);
stress2 = reshape(stress(2,:),nz,nx);
stress3 = reshape(stress(3,:),nz,nx);
stress4 = reshape(stress(4,:),nz,nx);
stress5 = reshape(stress(5,:),nz,nx);
stress6 = reshape(stress(6,:),nz,nx);
