#!/usr/bin/env octave

clear all
close all
clc

[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);
[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);

nbregions = nx*nz;

nx =[1:nx];
nz =[1:nz];

[NZ NX] = ndgrid(nz,nx);

regions = [repmat(reshape(NX,[],1),1,2) repmat(reshape(NZ,[],1),1,2)];

fileID = fopen(['../backup/nbregions'],'W');
fprintf(fileID, '\n')
fprintf(fileID, '#------------------------------------------------------------\n')
fprintf(fileID, 'nbregions                        = %i\n',nbregions)
fprintf(fileID, '#------------------------------------------------------------\n')
fclose(fileID);

fileID = fopen(['../backup/regions'],'w');

fmt = [repmat(' %d',1,4),'\n'];
fprintf(fileID,fmt, regions.')

fclose(fileID);
