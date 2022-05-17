#!/usr/bin/env octave

clear all
close all
clc

ARRAY_flag=1;

source=load('../backup/sr_utm');
receiver=load('../backup/rc_utm');
rc_range = norm(source-receiver);
rc_burial=-150;

[x_station]    = [-rc_range];
[z_station] = [rc_burial];

receiver = [x_station z_station];
save('-ascii','../backup/receiver','receiver');

networkName = 'RA';
elevation_station = zeros(size(x_station));
burial_station = zeros(size(x_station));

fileID = fopen(['../DATA/STATIONS'],'w');
stationNumber = length(x_station);
for nSTATIONS = 1:stationNumber
  stationName = ['S' int2str(nSTATIONS)];
  if ARRAY_flag
   fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,x_station(nSTATIONS),z_station(nSTATIONS),elevation_station(nSTATIONS),burial_station(nSTATIONS));
  end
end
fclose(fileID);

[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);
[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);

[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

[NELEM_PML_THICKNESS_status NELEM_PML_THICKNESS] = system('grep NELEM_PML_THICKNESS ../backup/Par_file.part | cut -d = -f 2');
NELEM_PML_THICKNESS = str2num(NELEM_PML_THICKNESS);

[x_station]    = [xmin+50:50:xmax-50];
[z_station] = [-10 :-10:zmin];

[x_station z_station] = ndgrid(x_station,z_station);

x_station = reshape(x_station,[],1);
z_station  = reshape(z_station,[],1);

water_sediment_interface = load('../backup/water_sediment_interface');
z_station_interp_on_water_sediment_interface    = interp1(water_sediment_interface(:,1),water_sediment_interface(:,2), x_station,'nearest');

mask_water = z_station > z_station_interp_on_water_sediment_interface+10;
x_station = x_station(find(mask_water));
z_station = z_station(find(mask_water));

networkName = 'SA';
elevation_station = zeros(size(x_station));
burial_station = zeros(size(x_station));

stationNumber = length(x_station);
fileID = fopen(['../DATA/STATIONS'],'a');
for nSTATIONS = 1:stationNumber
  stationName = ['S' int2str(nSTATIONS)];
  if ARRAY_flag
   fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,x_station(nSTATIONS),z_station(nSTATIONS),elevation_station(nSTATIONS),burial_station(nSTATIONS));
  end
end
fclose(fileID);
