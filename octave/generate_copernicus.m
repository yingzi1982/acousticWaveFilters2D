#!/usr/bin/env octave

pkg load netcdf

clear all
close all
clc

%ncdisp('../backup/copernicus.nc');
depth=ncread('../backup/copernicus.nc','depth');
longitude=ncread('../backup/copernicus.nc','longitude');
latitude=ncread('../backup/copernicus.nc','latitude');
time=ncread('../backup/copernicus.nc','time');

so=ncread('../backup/copernicus.nc','so');
thetao=ncread('../backup/copernicus.nc','thetao');
c= zeros(size(so));

for i = 1:length(depth)
  c(:,:,i,:) = sndspd(so(:,:,i,:),thetao(:,:,i,:),depth(i));
end

time_index_on_surface = 1;
depth_index_on_surface = 1;

so_on_surface = so(:,:,depth_index_on_surface,time_index_on_surface);
thetao_on_surface = thetao(:,:,depth_index_on_surface,time_index_on_surface);
c_on_surface = c(:,:,depth_index_on_surface,time_index_on_surface);


[LON LAT] = ndgrid(longitude,latitude);

so_on_surface = [reshape(LON,[],1) reshape(LAT,[],1) reshape(so_on_surface,[],1)];
thetao_on_surface = [reshape(LON,[],1) reshape(LAT,[],1) reshape(thetao_on_surface,[],1)];
c_on_surface = [reshape(LON,[],1) reshape(LAT,[],1) reshape(c_on_surface,[],1)];

save("-ascii",['../backup/so_on_surface'],'so_on_surface')
save("-ascii",['../backup/thetao_on_surface'],'thetao_on_surface')
save("-ascii",['../backup/c_on_surface'],'c_on_surface')

%-------------------------

sr = load('../backup/sr');
sr_longitude = sr(1);
sr_latitude = sr(2);

time_index_in_depth = 1;
[longitude_in_depth longitude_in_depth_index]=findNearest(longitude,sr_longitude);
[latitude_in_depth latitude_in_depth_index]=findNearest(latitude,sr_latitude);

so_in_depth = so(longitude_in_depth_index,latitude_in_depth_index,:,time_index_in_depth);
thetao_in_depth = thetao(longitude_in_depth_index,latitude_in_depth_index,:,time_index_in_depth);
c_in_depth = c(longitude_in_depth_index,latitude_in_depth_index,:,time_index_in_depth);


so_in_depth = [reshape(depth,[],1) reshape(so_in_depth,[],1)];
thetao_in_depth = [reshape(depth,[],1) reshape(thetao_in_depth,[],1)];
c_in_depth = [reshape(depth,[],1) reshape(c_in_depth,[],1)];

so_in_depth_index = ~isnan(so_in_depth(:,2));
thetao_in_depth_index = ~isnan(thetao_in_depth(:,2));
c_in_depth_index = ~isnan(c_in_depth(:,2));

so_in_depth = so_in_depth(so_in_depth_index,:);
thetao_in_depth = thetao_in_depth(thetao_in_depth_index,:);
c_in_depth = c_in_depth(c_in_depth_index,:);

%save("-ascii",['../backup/so_in_depth'],'so_in_depth')
%save("-ascii",['../backup/thetao_in_depth'],'thetao_in_depth')
%save("-ascii",['../backup/c_in_depth'],'c_in_depth')

depth_interp = [min(c_in_depth(:,1)):10:max(c_in_depth(:,1))]';

so_in_depth_interp = interp1(so_in_depth(:,1),so_in_depth(:,2),depth_interp,'spline');
so_in_depth_interp = [depth_interp so_in_depth_interp];

thetao_in_depth_interp = interp1(thetao_in_depth(:,1),thetao_in_depth(:,2),depth_interp,'spline');
thetao_in_depth_interp = [depth_interp thetao_in_depth_interp];

c_in_depth_interp = interp1(c_in_depth(:,1),c_in_depth(:,2),depth_interp,'spline');
c_in_depth_interp = [depth_interp c_in_depth_interp];

save("-ascii",['../backup/so_in_depth_interp'],'so_in_depth_interp')
save("-ascii",['../backup/thetao_in_depth_interp'],'thetao_in_depth_interp')
save("-ascii",['../backup/c_in_depth_interp'],'c_in_depth_interp')
