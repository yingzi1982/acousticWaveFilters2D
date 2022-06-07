#!/usr/bin/env octave

clear all
close all
clc

[xmin xmax zmin zmax step dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters;
dx = step;
dz = step;
nx = round((xmax-xmin)/dx+1);
nz = round((zmax-zmin)/dz+1);

dy = step;
ymin = -dy;
ymax = dy;
ny = 3;

x = linspace(xmin,xmax,nx);
y = linspace(ymin,ymax,ny);
z = linspace(zmin,zmax,nz);
[X Y Z] = meshgrid (x,y,z);
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
Ex = electricFields(:,[6]);
Ey = zeros(size(Ex));
Ez = electricFields(:,[7]);
E = [Ex Ey Ez];
E = transpose(E);
otherwise
disp(['Plesse input direct/converse!'])
end

stress = -transpose(piezoelectric_constant)*E;

stress1 = permute(repmat(permute((reshape(stress(1,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);
stress2 = permute(repmat(permute((reshape(stress(2,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);
stress3 = permute(repmat(permute((reshape(stress(3,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);
stress4 = permute(repmat(permute((reshape(stress(4,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);
stress5 = permute(repmat(permute((reshape(stress(5,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);
stress6 = permute(repmat(permute((reshape(stress(6,:),nz,nx)),[2 1]),1,1,3),[3,1 2]);

[stress1partialx, stress1partialy, stress1partialz] = gradient(stress1,dx,dy,dz);
[stress2partialx, stress2partialy, stress2partialz] = gradient(stress2,dx,dy,dz);
[stress3partialx, stress3partialy, stress3partialz] = gradient(stress3,dx,dy,dz);
[stress4partialx, stress4partialy, stress4partialz] = gradient(stress4,dx,dy,dz);
[stress5partialx, stress5partialy, stress5partialz] = gradient(stress5,dx,dy,dz);
[stress6partialx, stress6partialy, stress6partialz] = gradient(stress6,dx,dy,dz);

bodyforce_x = (stress1partialx + stress5partialz + stress6partialy);
bodyforce_y = (stress2partialy + stress4partialz + stress6partialx);
bodyforce_z = (stress3partialz + stress4partialy + stress5partialx);

Y_slice_index = 2;

X = squeeze(X(Y_slice_index,:,:));
Z = squeeze(Z(Y_slice_index,:,:));

bodyforce_x = squeeze(bodyforce_x(Y_slice_index,:,:));
bodyforce_z = squeeze(bodyforce_z(Y_slice_index,:,:));

[bodyforce_theta,bodyforce_rho] = cart2pol(bodyforce_x,bodyforce_z);
%format shortEng
%disp(['Max force amplitude = ' num2str(max(bodyforce_rho(:)))])
max(bodyforce_rho(:))

bodyforce=[reshape(X,[],1) reshape(Z,[],1) reshape(bodyforce_rho,[],1) reshape(bodyforce_theta,[],1) reshape(bodyforce_x,[],1) reshape(bodyforce_z,[],1)];
dlmwrite('../backup/bodyforceField',bodyforce,' ');
