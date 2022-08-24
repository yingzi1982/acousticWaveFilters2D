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

time_resample_rate=1;

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

resampled_point_number = 500;

switch filter_type
case 'SAW'

switch filter_dimension
case '2D'

LA_flag = 1;
SA_flag = 0;
%------------------------------------
if LA_flag
  LA_index = find(strcmp("LA",networkName));
  LA2_index = find(strcmp("LA2",networkName));

  LA_index = LA_index;
  LA2_index = LA2_index;

  LA_stationNumber = length(LA_index);
  LA2_stationNumber = length(LA2_index);
  if LA_stationNumber != LA2_stationNumber
    error('The station numbers of arrays LA and LA2 are not equal!');
  end

  LA_x = longorUTM(LA_index);
  %LA2_x = longorUTM(LA2_index);

  LA_z = latorUTM(LA_index);
  LA2_z = latorUTM(LA2_index);

  LA_z = [LA2_z(1);LA_z(1)];

  t = dlmread([signal_folder networkName{LA_index(1)} '.' stationName{LA_index(1)} band_x],'');
  t = t(1:time_resample_rate:end,1);
  t = t - t(1);
  
  dx = LA_x(2) - LA_x(1);
  dz = LA_z(2) - LA_z(1);
  dt = t(2) - t(1);

  LA_combined_signal_x = [];
  LA_combined_signal_z = [];
  for nStation = 1:LA_stationNumber
    signal_x = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
    signal_z = dlmread([signal_folder networkName{LA_index(nStation)} '.' stationName{LA_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
    LA_combined_signal_x = [LA_combined_signal_x signal_x((1:time_resample_rate:end))];
    LA_combined_signal_z = [LA_combined_signal_z signal_z((1:time_resample_rate:end))];
  end

  LA2_combined_signal_x = [];
  LA2_combined_signal_z = [];
  for nStation = 1:LA2_stationNumber
    signal2_x = dlmread([signal_folder networkName{LA2_index(nStation)} '.' stationName{LA2_index(nStation)} band_x],'',startRowNumber,startColumnNumber);
    signal2_z = dlmread([signal_folder networkName{LA2_index(nStation)} '.' stationName{LA2_index(nStation)} band_z],'',startRowNumber,startColumnNumber);
    LA2_combined_signal_x = [LA2_combined_signal_x signal2_x((1:time_resample_rate:end))];
    LA2_combined_signal_z = [LA2_combined_signal_z signal2_z((1:time_resample_rate:end))];
  end

  LA_combined_signal_together_x = [t LA_combined_signal_x];
  LA_combined_signal_together_z = [t LA_combined_signal_z];
  [LA_trace_image_x]=trace2image(LA_combined_signal_together_x,resampled_point_number,LA_x);
  [LA_trace_image_z]=trace2image(LA_combined_signal_together_z,resampled_point_number,LA_x);
  dlmwrite('../backup/LA_trace_image',[LA_trace_image_x LA_trace_image_z(:,end)],' ');
  %------------------------------------
  combined_signal_x = cat(3,LA2_combined_signal_x',LA_combined_signal_x');
  combined_signal_x = permute(combined_signal_x,[1 3 2]);

  combined_signal_z = cat(3,LA2_combined_signal_z',LA_combined_signal_z');
  combined_signal_z = permute(combined_signal_z,[1 3 2]);

  [combined_signal_x_partialx, combined_signal_x_partialz, combined_signal_x_partialt] = gradient(combined_signal_x,dx,dz,dt);
  [combined_signal_z_partialx, combined_signal_z_partialz, combined_signal_z_partialt] = gradient(combined_signal_z,dx,dz,dt);
  strain1 = combined_signal_x_partialx;
  strain2 = combined_signal_z_partialz;
  strain3 = combined_signal_x_partialz + combined_signal_z_partialx;

  LA_strain1 = transpose(squeeze(strain1(:,end,:)));
  LA_strain2 = transpose(squeeze(strain2(:,end,:)));
  LA_strain3 = transpose(squeeze(strain3(:,end,:)));
  [piezo]=generate_piezomaterial_parameters(filter_dimension);

  piezoelectric_constant = piezo.piezoelectric_constant;
  piezoelectric_constant = piezoelectric_constant([1 3],[1 3 5]);

  LA_electric_displacement_polarization_x = piezoelectric_constant(1,1)*LA_strain1 + piezoelectric_constant(1,2)*LA_strain2 + piezoelectric_constant(1,3)*LA_strain3;
  LA_electric_displacement_polarization_z = piezoelectric_constant(2,1)*LA_strain1 + piezoelectric_constant(2,2)*LA_strain2 + piezoelectric_constant(2,3)*LA_strain3;

  LA_electric_displacement_together_x_polarization = [t LA_electric_displacement_polarization_x];
  LA_electric_displacement_together_z_polarization = [t LA_electric_displacement_polarization_z];
  [LA_electric_displacement_image_x_polarization]=trace2image(LA_electric_displacement_together_x_polarization,resampled_point_number,LA_x);
  [LA_electric_displacement_image_z_polarization]=trace2image(LA_electric_displacement_together_z_polarization,resampled_point_number,LA_x);
  dlmwrite('../backup/LA_electric_displacement_polarization_image',[LA_electric_displacement_image_x_polarization LA_electric_displacement_image_z_polarization(:,end)],' ');

  %------------------------------------
  dielectric_constant = piezo.dielectric_constant;
  dielectric_constant = dielectric_constant([1 3],[1 3]);

  sourceTimeFunction = dlmread(['../backup/sourceTimeFunction'],'');

  electric_negative_finger = dlmread('../backup/electric_negative_finger','');
  electric_positive_finger = dlmread('../backup/electric_positive_finger','');

  negative_finger_electric_displacement_incident_x = dielectric_constant(1,1)*electric_negative_finger(:,1) + dielectric_constant(1,2)*electric_negative_finger(:,2);
  negative_finger_electric_displacement_incident_z = dielectric_constant(2,1)*electric_negative_finger(:,1) + dielectric_constant(2,2)*electric_negative_finger(:,2);

  positive_finger_electric_displacement_incident_x = dielectric_constant(1,1)*electric_positive_finger(:,1) + dielectric_constant(1,2)*electric_positive_finger(:,2);
  positive_finger_electric_displacement_incident_z = dielectric_constant(2,1)*electric_positive_finger(:,1) + dielectric_constant(2,2)*electric_positive_finger(:,2);

  negative_finger_electric_displacement_incident_x = sourceTimeFunction(:,2)*transpose(negative_finger_electric_displacement_incident_x);
  negative_finger_electric_displacement_incident_z = sourceTimeFunction(:,2)*transpose(negative_finger_electric_displacement_incident_z);

  positive_finger_electric_displacement_incident_x = sourceTimeFunction(:,2)*transpose(positive_finger_electric_displacement_incident_x);
  positive_finger_electric_displacement_incident_z = sourceTimeFunction(:,2)*transpose(positive_finger_electric_displacement_incident_z);
  %------------------------------------

  negative_finger=dlmread('../backup/negative_finger','');
  positive_finger=dlmread('../backup/positive_finger','');

  finger_dx = negative_finger(2,1)-negative_finger(1,1);
  if dx >= finger_dx
    dx_ratio = round(dx/finger_dx);
  else
    dx_ratio = 1;
  end

  negative_finger = negative_finger(1:dx_ratio:end,:);
  positive_finger = positive_finger(1:dx_ratio:end,:);
  finger_dx = negative_finger(2,1)-negative_finger(1,1);

  [negative_finger_x negative_finger_x_index]=findNearest(LA_x,negative_finger(:,1));
  [positive_finger_x positive_finger_x_index]=findNearest(LA_x,positive_finger(:,1));

  negative_finger_electric_displacement_x = LA_electric_displacement_polarization_x(:,negative_finger_x_index) + negative_finger_electric_displacement_incident_x;
  negative_finger_electric_displacement_z = LA_electric_displacement_polarization_z(:,negative_finger_x_index) + negative_finger_electric_displacement_incident_z;

  positive_finger_electric_displacement_x = LA_electric_displacement_polarization_x(:,positive_finger_x_index) + positive_finger_electric_displacement_incident_x;
  positive_finger_electric_displacement_z = LA_electric_displacement_polarization_z(:,positive_finger_x_index) + positive_finger_electric_displacement_incident_z;

  charge_on_positive_electrode = sum(-finger_dx*positive_finger_electric_displacement_z,2);
  charge_on_negative_electrode = sum(-finger_dx*negative_finger_electric_displacement_z,2);

  charge = charge_on_positive_electrode;
  current = -gradient(charge,dt);

  charge = [t charge];
  current = [t current];

  dlmwrite(['../backup/charge'],charge,' ');
  dlmwrite(['../backup/current'],current,' ');

  %current_envelope = trace2envelope(current,resampled_point_number);
  %dlmwrite(['../backup/current_envelope'],current_envelope,' ');

  current_spectrum = trace2spectrum(current);
  dlmwrite(['../backup/current_spectrum'],current_spectrum,' ');
  
  current_specgram = trace2specgram(current);
  dlmwrite(['../backup/current_specgram'],current_specgram,' ');

  voltage = sourceTimeFunction;

  voltage_spectrum = trace2spectrum(voltage);

  f = current_spectrum(:,1);
  voltage_spectrum = [f interp1(voltage_spectrum(:,1),voltage_spectrum(:,2),f,'linear')];

  %------------------------------------
  admittance_spectrum = current_spectrum(:,2)./voltage_spectrum(:,2);
  %------------------------------------
  %number_of_step = 200;
  %step = round(length(t)/number_of_step);
  %window = 8*step;
  %nfft = 2^nextpow2(8*window);
  %noverlap= window-step;
  %nfft = 2^nextpow2(length(t));
 
  %fs = 1/dt;
  %[admittance_spectrum f] = tfestimate (voltage(:,2), current(:,2), window,noverlap, nfft, fs);
  %------------------------------------

  f_cut_min = 0.1e9;
  f_cut_max = 2.9e9;
  select_index = find(f>=f_cut_min & f<=f_cut_max);
  f = f(select_index);

  admittance_spectrum = admittance_spectrum(select_index);

  admittance_spectrum = 20*log10(admittance_spectrum/max(admittance_spectrum));

  min(admittance_spectrum)
  max(admittance_spectrum)

  admittance_spectrum = [f admittance_spectrum];

  dlmwrite(['../backup/admittance_spectrum'],admittance_spectrum,' ');
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
