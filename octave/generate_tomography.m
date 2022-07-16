#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();

if length(arg_list) > 0
  filter_dimension = arg_list{1};
else
  error("Please input filter dimension.")
end

[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);
[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);

[ymin_status ymin] = system('grep ymin ../backup/meshInformation | cut -d = -f 2');
ymin = str2num(ymin);
[ymax_status ymax] = system('grep ymax ../backup/meshInformation | cut -d = -f 2');
ymax = str2num(ymax);
[dy_status dy] = system('grep dy ../backup/meshInformation | cut -d = -f 2');
dy = str2num(dy);

[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

nx = round((xmax - xmin)/dx);
ny = round((ymax - ymin)/dy);
nz = round((zmax - zmin)/dz);

%[NELEM_PML_THICKNESS_status NELEM_PML_THICKNESS] = system('grep NELEM_PML_THICKNESS ../backup/Par_file.part | cut -d = -f 2');
%NELEM_PML_THICKNESS = str2num(NELEM_PML_THICKNESS);
switch filter_dimension
case '2D'

%-------------------------------------------------
readMeshFromFile='no';
if strcmp(readMeshFromFile,'yes')
  %disp(['reading mesh from file ../backup/mesh.xz'])
  %mesh=dlmread('../backup/mesh.xz'); 
  %x_mesh = mesh(:,1);
  %z_mesh = mesh(:,2);

  %x_mesh = reshape(reshape(x_mesh,[],1),nz,nx);
  %z_mesh = reshape(reshape(z_mesh,[],1),nz,nx);
else
  disp(['creating regular mesh'])
  x_mesh = [xmin+dx/2:dx:xmax-dx/2];
  z_mesh = [zmin+dz/2:dz:zmax-dz/2];

  [z_mesh x_mesh] = ndgrid(z_mesh,x_mesh);
end

%-------------------------------------------------

%%z_mesh_interp_on_piezo_top_interface    = interp1(x_piezo,z_piezo_top_interface, x_mesh,'nearest');
%%z_mesh_interp_on_piezo_bottom_interface = interp1(x_piezo,z_piezo_bottom_interface, x_mesh,'nearest');
%%
%%x_mesh_interp_on_piezo_left_interface  = interp1(z_piezo,x_piezo_left_interface, z_mesh,'nearest');
%%x_mesh_interp_on_piezo_right_interface = interp1(z_piezo,x_piezo_right_interface, z_mesh,'nearest');
%%
%%mask_piezo = (z_mesh <= z_mesh_interp_on_piezo_top_interface & z_mesh >= z_mesh_interp_on_piezo_bottom_interface) ...
           %%& (x_mesh <= x_mesh_interp_on_piezo_right_interface & x_mesh >= x_mesh_interp_on_piezo_left_interface);
%%
%%mask_piezo = [reshape(mask_piezo,[],1)];
%%dlmwrite('../backup/mask_piezo',mask_piezo);


%-------------------------------------------------
regionsMaterialNumbering = zeros(size(z_mesh));
piezo_material_numbering = 1;
[piezo]=generate_piezomaterial_parameters(filter_dimension);
polygon_piezo = piezo.polygon;
[in,on] = inpolygon (x_mesh, z_mesh, polygon_piezo(:,1), polygon_piezo(:,2));
mask_piezo = in | on;
regionsMaterialNumbering(find(mask_piezo)) = piezo_material_numbering;

regionsMaterialNumbering = [reshape(regionsMaterialNumbering,[],1)];

dlmwrite('../backup/regionsMaterialNumbering',regionsMaterialNumbering,' ');

case '3D'
otherwise
error('Wrong flter dimension!')
end
