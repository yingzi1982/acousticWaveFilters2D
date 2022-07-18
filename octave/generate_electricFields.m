#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  filter_type  = arg_list{1};
  filter_dimension = arg_list{2};
else
  error('Please input filter type and dimension.');
end

[piezo]=generate_piezomaterial_parameters(filter_dimension);

dx = piezo.dx;
dy = piezo.dy;
dz = piezo.dz;

x = piezo.x;
y = piezo.y;
z = piezo.z;
%---------------------------------
positive_finger_V = 1;
negative_finger_V = 0;
%---------------------------------
positive_finger = dlmread('../backup/positive_finger',' ');
negative_finger = dlmread('../backup/negative_finger',' ');

switch filter_dimension
case '2D'

[X Z] = meshgrid (x,z);
%V = relaxationMethod(x,y,z,positive_finger,negative_finger,positive_finger_V,negative_finger_V,filter_dimension);
V = summationMethod(x,y,z,positive_finger,negative_finger,positive_finger_V,negative_finger_V,filter_dimension);


[E_x E_z] = gradient(V,dx,dz);
E_x = -E_x;
E_z = -E_z;

[E_theta,E_rho] = cart2pol(E_x,E_z);

electric=[reshape(X,[],1) reshape(Z,[],1) reshape(E_rho,[],1) reshape(E_theta,[],1) [reshape(E_x,[],1) reshape(E_z,[],1)]];
potential=[reshape(X,[],1) reshape(Z,[],1) [reshape(V,[],1)]];
case '3D'
otherwise
error('Wrong filter dimension!')
end

dlmwrite('../backup/electric',electric,' ');
dlmwrite('../backup/potential',potential,' ');
