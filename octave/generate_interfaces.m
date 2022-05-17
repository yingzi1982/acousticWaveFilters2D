#!/usr/bin/env octave

clear all
close all
clc

[NELEM_PML_THICKNESSStatus NELEM_PML_THICKNESS] = system('grep NELEM_PML_THICKNESS ../backup/Par_file.part | cut -d = -f 2');
NELEM_PML_THICKNESS = str2num(NELEM_PML_THICKNESS);

[xminStatus xmin] = system('grep xmin ../backup/Par_file.part | cut -d = -f 2');
xmin = str2num(xmin);

[xmaxStatus xmax] = system('grep xmax ../backup/Par_file.part | cut -d = -f 2');
xmax = str2num(xmax);

[nxStatus nx] = system('grep nx ../backup/Par_file.part | cut -d = -f 2');
nx = str2num(nx);
xNumber = nx + 1;

dx = (xmax - xmin)/nx;
x=linspace(xmin,xmax,xNumber);

%zmin = xmin;
%zmax = xmax;
zmin=-3600;
zmax = 0;
dz = dx;

nz = round((zmax - zmin)/dz);

fileID = fopen(['../backup/meshInformation'],'w');
fprintf(fileID, 'xmin = %f\n', xmin);
fprintf(fileID, 'zmin = %f\n', zmin);

fprintf(fileID, '\n');

fprintf(fileID, 'xmax = %f\n', xmax);
fprintf(fileID, 'zmax = %f\n', zmax);

fprintf(fileID, '\n');

fprintf(fileID, 'dx = %f\n', dx);
fprintf(fileID, 'dz = %f\n', dz);

fprintf(fileID, '\n');

fprintf(fileID, 'nx = %i\n', nx);
fprintf(fileID, 'nz = %i\n', nz);
fclose(fileID);

interfaces = [zmin zmax];

layers = [nz];

subInterfaces = repmat(transpose(interfaces),[1,xNumber]);

%subInterfaces(end,:) = interp1(TOPO_slice(1,:),TOPO_slice(2,:),x);

fileID = fopen(['../DATA/interfaces.dat'],'w');
fprintf(fileID, '%i\n', length(interfaces))
fprintf(fileID, '%s\n', '#')
for ninterface = [1:length(interfaces)]
  fprintf(fileID, '%i\n', xNumber)
  fprintf(fileID, '%s\n', '#')
  for ix = [1:xNumber]
    fprintf(fileID, '%f %f\n', [x(ix), subInterfaces(ninterface,ix)])
  end
  fprintf(fileID, '%s\n', '#')
end

for nlayer = [1:length(layers)] 
  fprintf(fileID, '%i\n', layers(nlayer))
  fprintf(fileID, '%s\n', '#')
end
fclose(fileID);
