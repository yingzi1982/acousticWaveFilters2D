#!/usr/bin/env octave

clear all
close all
clc

[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);
[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);
[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);

[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);
[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

[NELEM_PML_THICKNESS_status NELEM_PML_THICKNESS] = system('grep NELEM_PML_THICKNESS ../backup/Par_file.part | cut -d = -f 2');
NELEM_PML_THICKNESS = str2num(NELEM_PML_THICKNESS);

x = linspace(xmin,xmax,nx+1);

rc=load('../backup/rc_utm');
rc_longorUTM = rc(:,1);
rc_latorUTM = rc(:,2);

sr=load('../backup/sr_utm');
sr_longorUTM = sr(:,1);
sr_latorUTM = sr(:,2);
k=(sr_latorUTM-rc_latorUTM)/(sr_longorUTM -rc_longorUTM);

offset=1000;
nrange = nx;
range_x = linspace(min(rc_longorUTM,sr_longorUTM)-offset,max(rc_longorUTM,sr_longorUTM)+offset,nrange);
range_y = k*range_x;

topo=load('../backup/topo.xyz');
topo = griddata (topo(:,1), topo(:,2), topo(:,3), range_x, range_y,'linear');

left_range_index = find(range_x<=0);
right_range_index = find(range_x>0);
left_range = -sqrt(range_x(left_range_index).^2+range_y(left_range_index).^2);
right_range = sqrt(range_x(right_range_index).^2+range_y(right_range_index).^2);
range = [left_range';right_range'];

topo = interp1(range,topo,x,'linear');

water_sediment_interface = topo;
dlmwrite('../backup/water_sediment_interface',[x' water_sediment_interface'],' ');

sediment_sediment_interface = topo - 600;
%model_1
%sediment_rock_interface = topo - 600 - 980;
%model_2
sediment_rock_interface = topo - 600 - 600;
%sediment_rock_interface = topo - 600 - 4000;
top_interface = zmax*ones(size(topo));
bottom_interface = zmin*ones(size(topo));

fileID = fopen(['../backup/interfacesInformation'],'w');
  fprintf(fileID,'water_sediment_interface_min = %f\n',min(water_sediment_interface(:)));
  fprintf(fileID,'water_sediment_interface_max = %f\n',max(water_sediment_interface(:)));
  fprintf(fileID,'sediment_sediment_interface_min = %f\n',min(sediment_sediment_interface(:)));
  fprintf(fileID,'sediment_sediment_interface_max = %f\n',max(sediment_sediment_interface(:)));
  fprintf(fileID,'sediment_rock_interface_min  = %f\n',min(sediment_rock_interface(:)));
  fprintf(fileID,'sediment_rock_interface_max  = %f\n',max(sediment_rock_interface(:)));
fclose(fileID);

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

upper_sediment_material_numbering = 1;
lower_sediment_material_numbering = 2;
rock_material_numbering = 3;
upper_sediment_pml_material_numbering = 4;
lower_sediment_pml_material_numbering = 5;
rock_pml_material_numbering = 6;

%---------------------------

z_mesh_interp_on_water_sediment_interface    = interp1(x,water_sediment_interface, x_mesh,'nearest');
z_mesh_interp_on_sediment_sediment_interface = interp1(x,sediment_sediment_interface, x_mesh,'nearest');
z_mesh_interp_on_sediment_rock_interface     = interp1(x,sediment_rock_interface, x_mesh,'nearest');

mask_water = z_mesh > z_mesh_interp_on_water_sediment_interface;
mask_upper_sediment = z_mesh <= z_mesh_interp_on_water_sediment_interface & z_mesh > z_mesh_interp_on_sediment_sediment_interface;
mask_lower_sediment = z_mesh <= z_mesh_interp_on_sediment_sediment_interface & z_mesh > z_mesh_interp_on_sediment_rock_interface;
mask_rock = z_mesh <= z_mesh_interp_on_sediment_rock_interface;

regionsMaterialNumbering = zeros(size(z_mesh));

%---------------------------
materials = load('../backup/models');

% use copernicus or measured sound speed profile in water column
c_in_depth=load('../backup/c_in_depth_interp');
disp('copernicus sound speed profile is adopted')
%c_in_depth=load('../backup/c_in_depth_measured_interp');
%disp('measured sound speed profile is adopted')
c_in_depth_500 = load('../backup/ssp500');
c_in_depth_500_column = 3;
disp(['Top 500m ssp with measured data of column ' int2str(c_in_depth_500_column)])
%c_in_depth_500 = c_in_depth_500()


index = find(c_in_depth(:,1)>500);
c_in_depth = [c_in_depth_500(:,[1 c_in_depth_500_column]);c_in_depth(index,:)];

depth_interp = [zmin:5:zmax]';
c_in_depth = interp1(-c_in_depth(:,1),c_in_depth(:,2),depth_interp,'spline','extrap');
c_in_depth = [depth_interp c_in_depth];

water_z = z_mesh(mask_water);
[water_z water_z_index] = findNearest(c_in_depth(:,1),water_z);
water_sound_speed = c_in_depth(water_z_index,2);
[water_sound_speed water_sound_speed_index] = findNearest(materials(:,4),water_sound_speed);
water_materials_numbering = materials(water_sound_speed_index,1);

%---------------------------
%water_materials_numbering = 7;
%---------------------------

regionsMaterialNumbering(find(mask_water)) = water_materials_numbering;

regionsMaterialNumbering(find(mask_upper_sediment)) = upper_sediment_material_numbering;
regionsMaterialNumbering(find(mask_lower_sediment)) = lower_sediment_material_numbering;
regionsMaterialNumbering(find(mask_rock)) = rock_material_numbering;

%--------------------------
NELEM_PML_THICKNESS = NELEM_PML_THICKNESS;

xmin_edge_numbering=NELEM_PML_THICKNESS+1;
xmax_edge_numbering=nx-NELEM_PML_THICKNESS;
zmin_edge_numbering=NELEM_PML_THICKNESS+1;

mask_edge_numbering=zeros(size(regionsMaterialNumbering));
mask_edge_numbering(:,[xmin_edge_numbering xmax_edge_numbering])=1;
mask_edge_numbering([zmin_edge_numbering],:)=1;

regionsMaterialNumbering(find(mask_upper_sediment&mask_edge_numbering)) = upper_sediment_pml_material_numbering;
regionsMaterialNumbering(find(mask_lower_sediment&mask_edge_numbering)) = lower_sediment_pml_material_numbering;
regionsMaterialNumbering(find(mask_rock&mask_edge_numbering)) = rock_pml_material_numbering;

xmin_layer_index=1:xmin_edge_numbering-1;
xmax_layer_index=xmax_edge_numbering+1:nx;
zmin_layer_index=1:zmin_edge_numbering-1;

regionsMaterialNumbering(:,xmin_layer_index) = repmat(regionsMaterialNumbering(:,xmin_edge_numbering),[1,NELEM_PML_THICKNESS]);
regionsMaterialNumbering(:,xmax_layer_index) = repmat(regionsMaterialNumbering(:,xmax_edge_numbering),[1,NELEM_PML_THICKNESS]);

regionsMaterialNumbering(zmin_layer_index,:) = repmat(regionsMaterialNumbering(zmin_edge_numbering,:),[NELEM_PML_THICKNESS,1]);

regionsMaterialNumbering(zmin_layer_index,xmin_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,xmin_edge_numbering),[NELEM_PML_THICKNESS,NELEM_PML_THICKNESS]);
regionsMaterialNumbering(zmin_layer_index,xmax_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,xmax_edge_numbering),[NELEM_PML_THICKNESS,NELEM_PML_THICKNESS]);
%%---------------------------


regionsMaterialNumbering = [reshape(regionsMaterialNumbering,[],1)];

dlmwrite('../backup/regionsMaterialNumbering',regionsMaterialNumbering,' ');

top_interface = [x' top_interface'];
bottom_interface = [x' bottom_interface'];
water_sediment_interface = [x' water_sediment_interface'];
sediment_sediment_interface = [x' sediment_sediment_interface'];
sediment_rock_interface= [x' sediment_rock_interface'];

water_polygon = [top_interface;flipud(water_sediment_interface)];
upper_sediment_polygon = [water_sediment_interface;flipud(sediment_sediment_interface)];
lower_sediment_polygon = [sediment_sediment_interface;flipud(sediment_rock_interface)];
rock_polygon = [sediment_rock_interface;flipud(bottom_interface)];

dlmwrite('../backup/water_polygon',water_polygon,' ');
dlmwrite('../backup/upper_sediment_polygon',upper_sediment_polygon,' ');
dlmwrite('../backup/lower_sediment_polygon',lower_sediment_polygon,' ');
dlmwrite('../backup/rock_polygon',rock_polygon,' ');

[regionsMaterialNumbering regionsMaterialNumbering_index] = findNearest(materials(:,1),regionsMaterialNumbering);
mesh_sound_speed = [[reshape(x_mesh,[],1)] [reshape(z_mesh,[],1)] materials(regionsMaterialNumbering_index,4)];
dlmwrite('../backup/mesh_sound_speed',mesh_sound_speed,' ');
