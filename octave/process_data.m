#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  filter_type = arg_list{1};
  filter_dimension = arg_list{2};
else
  error("Please input filter type and filter dimension.")
end

[runningNameStatus runningName] = system('grep ^title ../DATA/Par_file | cut -d = -f 2');
signal_folder=['/cfs/klemming/projects/snic/snic2022-22-620/yingzi/' strtrim(runningName) '/OUTPUT_FILES/'];

%backup_folder=['../backup/'];

time_resample_rate=2;
station_resample_rate=2;

startRowNumber=0;
startColumnNumber=1;

fileID = fopen(['../DATA/STATIONS']);
station = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
elevation = station{5};
burial = station{6};
stationNumber = length(stationName);
band_x='.BXX.semd';
band_y='.BXY.semd';
band_z='.BXZ.semd';

switch filter_type
case 'SAW'

switch filter_dimension
case '2D'

LA_flag =1;
SA_flag=1;

%------------------------------------
if LA_flag
  LA_index=find(strcmp("LA",networkName));
  LA_index = LA_index(1:station_resample_rate:end);

  LA_stationNumber=length(LA_index);

  LA_range = longorUTM(LA_index);

  t = dlmread([signal_folder networkName{LA_index(1)} '.' stationName{LA_index(1)} band_x],'');
  t = t(:,1);
  t = t - t(1);

  LA_combined_signal_x = [];
  LA_combined_signal_z = [];

  for nStation = 1:LA_stationNumber
    signal_x = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
    signal_z = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
    LA_combined_signal_x = [LA_combined_signal_x signal_x((1:time_resample_rate:end))];
    LA_combined_signal_z = [LA_combined_signal_z signal_z((1:time_resample_rate:end))];
  end
LA_combined_signal_x = [t(1:time_resample_rate:end) LA_combined_signal_x];
LA_combined_signal_z = [t(1:time_resample_rate:end) LA_combined_signal_z];
LA_nt = 500;
[LA_trace_image_x]=trace2image(LA_combined_signal_x,LA_nt,LA_range);
[LA_trace_image_z]=trace2image(LA_combined_signal_z,LA_nt,LA_range);
dlmwrite('../backup/LA_trace_image',[LA_trace_image_x LA_trace_image_z(:,end)],' ');
end

%------------------------------------
if SA_flag
  SA_set = {'SA'};
  snapshot_start = 500;
  snapshot_step = 500;
  snapshot_end=length(t);
  snapshot_index = snapshot_start:snapshot_step:snapshot_end;
  snapshot_number = length(snapshot_index);
  dlmwrite('../backup/snapshot_time',t(snapshot_index),' ');

  for nSA=1:length(SA_set)
    SA_name=SA_set{nSA};
    SA_index=find(strcmp(SA_name,networkName));
    SA_stationNumber=length(SA_index);

    dlmwrite(['../backup/' SA_name '_coordinate'],[longorUTM(SA_index) latorUTM(SA_index)],' ');

    segementLength=100;
    segementNumber=ceil(SA_stationNumber/segementLength);

    snapshots_x = [];
    snapshots_z = [];

    for nSegement = 1:segementNumber
      SA_x=[];
      SA_z=[];
    for nSegementStation = 1:segementLength
      nStation = nSegementStation + (nSegement -1)*segementLength;
    if nStation<=SA_stationNumber
      signal_x = dlmread([signal_folder networkName{SA_index(nStation)} '.' stationName{SA_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
      signal_z = dlmread([signal_folder networkName{SA_index(nStation)} '.' stationName{SA_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
      SA_x = [SA_x signal_x(snapshot_index)];
      SA_z = [SA_z signal_z(snapshot_index)];
    end
    end
    snapshots_x=[snapshots_x;transpose(SA_x)];
    snapshots_z=[snapshots_z;transpose(SA_z)];
    end
    dlmwrite(['../backup/' SA_name '_snapshots_x'],snapshots_x,' ');
    dlmwrite(['../backup/' SA_name '_snapshots_z'],snapshots_z,' ');
  end
end
case '3D'
otherwise
error('Wrong filter dimension!')
end

case 'BAW'
switch filter_dimension
case '2D'
case '3D'
otherwise
error('Wrong filter dimension!')
end
otherwise
error('Wrong filter type!')
end
