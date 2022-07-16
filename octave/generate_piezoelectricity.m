#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  piezoelectric_effect = arg_list{1};
  filter_dimension = arg_list{2};
else
  error('Please input direct or converse piezoelectric effect and filter dimension');
end

[piezo]=generate_piezomaterial_parameters(filter_dimension);
xmin = piezo.xmin;
ymin = piezo.ymin;            
zmin = piezo.zmin;            

xmax = piezo.xmax;            
ymax = piezo.ymax;            
zmax = piezo.zmax;            

dx = piezo.dx;                
dy = piezo.dy;                
dz = piezo.dz;                

nx = round((xmax-xmin)/dx+1);
ny = round((ymax-ymin)/dy+1);
nz = round((zmax-zmin)/dz+1);

x = linspace(xmin,xmax,nx);
y = linspace(xmin,xmax,nx);
z = linspace(zmin,zmax,nz);

piezoelectric_constant = piezo.piezoelectric_constant;

switch piezoelectric_effect
case 'direct'
%
case 'converse'
switch filter_dimension
case '2D'
  [X Z] = meshgrid(x,z);
  electric=dlmread('../backup/electric');
  Ex = electric(:,[5]);
  Ez = electric(:,[6]);
  E = [Ex Ez];
  E = transpose(E);
  piezoelectric_constant = piezoelectric_constant([1 3],[1 3 5]);

  stress = -transpose(piezoelectric_constant)*E;

  stress1 = reshape(stress(1,:),nz,nx);
  stress2 = reshape(stress(2,:),nz,nx);
  stress3 = reshape(stress(3,:),nz,nx);

  [stress1partialx, stress1partialz] = gradient(stress1,dx,dz);
  [stress2partialx, stress2partialz] = gradient(stress2,dx,dz);
  [stress3partialx, stress3partialz] = gradient(stress3,dx,dz);

  bodyforce_x = (stress1partialx + stress3partialz);
  bodyforce_z = (stress2partialz + stress3partialx);
  [bodyforce_theta,bodyforce_rho] = cart2pol(bodyforce_x,bodyforce_z);

  bodyforce=[reshape(X,[],1) reshape(Z,[],1) reshape(bodyforce_rho,[],1) reshape(bodyforce_theta,[],1) reshape(bodyforce_x,[],1) reshape(bodyforce_z,[],1)];
  polygon_piezo = piezo.polygon;
  [in,on] = inpolygon (bodyforce(:,1), bodyforce(:,2), polygon_piezo(:,1), polygon_piezo(:,2));
  mask_piezo = in | on;
  bodyforce = bodyforce(mask_piezo,:);

case '3D'
  %[X Y Z] = meshgrid(x,y,z);
  %electric=dlmread('../backup/electric');
  %Ex = electric(:,[6]);
  %Ey = zeros(size(Ex));
  %Ez = electric(:,[7]);
  %E = [Ex Ey Ez];
  %E = transpose(E);
 
  %stress = -transpose(piezoelectric_constant)*E;
 
  %stress1 = reshape(stress(1,:),ny,nx,nz);
  %stress2 = reshape(stress(2,:),ny,nx,nz);
  %stress3 = reshape(stress(3,:),ny,nx,nz);
  %stress4 = reshape(stress(4,:),ny,nx,nz);
  %stress5 = reshape(stress(5,:),ny,nx,nz);
  %stress6 = reshape(stress(6,:),ny,nx,nz);
 
  %[stress1partialx, stress1partialy, stress1partialz] = gradient(stress1,dx,dy,dz);
  %[stress2partialx, stress2partialy, stress2partialz] = gradient(stress2,dx,dy,dz);
  %[stress3partialx, stress3partialy, stress3partialz] = gradient(stress3,dx,dy,dz);
  %[stress4partialx, stress4partialy, stress4partialz] = gradient(stress4,dx,dy,dz);
  %[stress5partialx, stress5partialy, stress5partialz] = gradient(stress5,dx,dy,dz);
  %[stress6partialx, stress6partialy, stress6partialz] = gradient(stress6,dx,dy,dz);
 
  %bodyforce_x = (stress1partialx + stress5partialz + stress6partialy);
  %bodyforce_y = (stress2partialy + stress4partialz + stress6partialx);
  %bodyforce_z = (stress3partialz + stress4partialy + stress5partialx);
 
 
  %%[bodyforce_azimuth,bodyforce_elevation, bodyforce_rho] = cart2sph(bodyforce_x,bodyforce_y,bodyforce_z);
  %%bodyforce=[reshape(X,[],1) reshape(Z,[],1) reshape(bodyforce_azimuth,[],1) reshape(bodyforce_elevation,[],1)  reshape(bodyforce_rho,[],1)reshape(bodyforce_x,[],1) reshape(bodyforce_y,[],1) reshape(bodyforce_z,[],1)];
otherwise
error('Wrong filter dimension!')
end
otherwise
error('Wrong piezoelectric effect!')

end
dlmwrite('../backup/bodyforce',bodyforce,' ');
