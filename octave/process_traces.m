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

startRowNumber=0;
startColumnNumber=1;

fileID = fopen([signal_folder 'output_list_stations.txt']);
station = textscan(fileID,'%s %s %f %f');
fclose(fileID);
stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};

stationNumber = length(stationName);

band_x='.BXX.semd';
band_y='.BXY.semd';
band_z='.BXZ.semd';

time_resample_rate=1;
time_resampled_point_number = 500;
sourceTimeFunction = dlmread([signal_folder 'plot_source_time_function.txt'],'');
t = sourceTimeFunction(1:time_resample_rate:end,1);
t = t - t(1);

switch filter_type
case 'SAW'

switch filter_dimension
case '2D'

PF_flag = 1;
LA_flag = 0;
SA_flag = 0;
%------------------------------------
if PF_flag

  dx = longorUTM(2)-longorUTM(1);
  dz = latorUTM(1)-latorUTM(stationNumber/2+1);
  dt = t(2) - t(1);

  PF_index  = find(strcmp("PF",networkName));
  PF2_index = find(strcmp("PF2",networkName));

  PF_stationNumber = length(PF_index);
  PF2_stationNumber = length(PF2_index);

  finger_pair_number = dlmread('../backup/finger_pair_number','');
  finger_point_number = PF_stationNumber/finger_pair_number;

  if (PF_stationNumber != PF2_stationNumber) && (mod(finger_point_number,1) != 0)
    error('The vaules for PF and PF2 arrays are not correctly set!');
  end

  [piezo]=generate_piezomaterial_parameters(filter_dimension);
  piezoelectric_constant = piezo.piezoelectric_constant;
  piezoelectric_constant = piezoelectric_constant([1 3],[1 3 5]);
  dielectric_constant = piezo.dielectric_constant;
  dielectric_constant = dielectric_constant([1 3],[1 3]);

  PF_charge_piezo = 0;
  for n = 1:finger_pair_number
  %for n = 11:11
    nIndex = [1:finger_point_number] + (n-1)*finger_point_number;

    nPF_index = PF_index(nIndex);
    nPF2_index = PF2_index(nIndex);

    nPF_combined_signal_x = [];
    nPF_combined_signal_z = [];

    nPF2_combined_signal_x = [];
    nPF2_combined_signal_z = [];

    for nStation = 1:finger_point_number
      signal_x = dlmread([signal_folder networkName{nPF_index(nStation)} '.' stationName{nPF_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
      signal_z = dlmread([signal_folder networkName{nPF_index(nStation)} '.' stationName{nPF_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
      nPF_combined_signal_x = [nPF_combined_signal_x signal_x((1:time_resample_rate:end))];
      nPF_combined_signal_z = [nPF_combined_signal_z signal_z((1:time_resample_rate:end))];

      signal2_x = dlmread([signal_folder networkName{nPF2_index(nStation)} '.' stationName{nPF2_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
      signal2_z = dlmread([signal_folder networkName{nPF2_index(nStation)} '.' stationName{nPF2_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
      nPF2_combined_signal_x = [nPF2_combined_signal_x signal2_x((1:time_resample_rate:end))];
      nPF2_combined_signal_z = [nPF2_combined_signal_z signal2_z((1:time_resample_rate:end))];
    end

    combined_signal_x = cat(3,nPF2_combined_signal_x',nPF_combined_signal_x');
    combined_signal_x = permute(combined_signal_x,[1 3 2]);

    combined_signal_z = cat(3,nPF2_combined_signal_z',nPF_combined_signal_z');
    combined_signal_z = permute(combined_signal_z,[1 3 2]);

    [combined_signal_x_partialx, combined_signal_x_partialz, combined_signal_x_partialt] = gradient(combined_signal_x,dx,dz,dt);
    [combined_signal_z_partialx, combined_signal_z_partialz, combined_signal_z_partialt] = gradient(combined_signal_z,dx,dz,dt);

    strain1 = combined_signal_x_partialx;
    strain2 = combined_signal_z_partialz;
    strain3 = combined_signal_x_partialz + combined_signal_z_partialx;

    nPF_strain1 = transpose(squeeze(strain1(:,end,:)));
    nPF_strain2 = transpose(squeeze(strain2(:,end,:)));
    nPF_strain3 = transpose(squeeze(strain3(:,end,:)));
 
    nPF_electric_displacement_piezo_x = piezoelectric_constant(1,1)*nPF_strain1 + piezoelectric_constant(1,2)*nPF_strain2 + piezoelectric_constant(1,3)*nPF_strain3;
    nPF_electric_displacement_piezo_z = piezoelectric_constant(2,1)*nPF_strain1 + piezoelectric_constant(2,2)*nPF_strain2 + piezoelectric_constant(2,3)*nPF_strain3;

    nPF_charge_piezo = sum(-dx*nPF_electric_displacement_piezo_z,2);
    PF_charge_piezo = PF_charge_piezo + nPF_charge_piezo;
  end

max(PF_charge_piezo)
dlmwrite('../backup/PF_charge_piezo',[t PF_charge_piezo],' ');
exit
end
exit
%------------------------------------
if LA_flag
  LA_index = find(strcmp("LA",networkName));
  LA_stationNumber = length(LA_index);

  LA_x = longorUTM(LA_index);

  LA_combined_signal_x = [];
  LA_combined_signal_z = [];
  for nStation = 1:LA_stationNumber
    signal_x = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
    signal_z = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
    LA_combined_signal_x = [LA_combined_signal_x signal_x((1:time_resample_rate:end))];
    LA_combined_signal_z = [LA_combined_signal_z signal_z((1:time_resample_rate:end))];
  end

  LA_combined_signal_together_x = [t LA_combined_signal_x];
  LA_combined_signal_together_z = [t LA_combined_signal_z];
  [LA_trace_image_x]=trace2image(LA_combined_signal_together_x,time_resampled_point_number,LA_x);
  [LA_trace_image_z]=trace2image(LA_combined_signal_together_z,time_resampled_point_number,LA_x);

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
  dlmwrite('../backup/snapshot_time',t(snapshot_index,1),' ');

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
error('Wrong filter dimension!')
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
