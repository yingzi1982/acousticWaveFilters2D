#!/usr/bin/env octave

clear all
close all
clc

CARRAY_flag =1;

backup_folder=['../backup/'];
DATA_folder=['../DATA/'];
%signal_folder=['../OUTPUT_FILES/'];
signal_folder=['/ichec/work/ngear019b/yingzi/18A/OUTPUT_FILES/'];

%receiver = load([backup_folder 'receiver']);

source_signal = load([backup_folder 'plot_source_time_function.txt']);
t = source_signal(:,1);

[ATTENUATION_f0_REFERENCEStatus ATTENUATION_f0_REFERENCE] = system('grep ^ATTENUATION_f0_REFERENCE ../backup/Par_file.part | cut -d = -f 2');
ATTENUATION_f0_REFERENCE = str2num(ATTENUATION_f0_REFERENCE);
f0 = ATTENUATION_f0_REFERENCE;

resample_rate=1;

startRowNumber=0;
startColumnNumber=1;

%----------------------------

fileID = fopen([DATA_folder 'STATIONS']);
station = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
station_x = station{3};
station_z = station{4};
[station_theta,station_rho] = cart2pol(station_x,station_z);


stationNumber = length(stationName);
band='.PRE.semp';
%------------------------------------
if CARRAY_flag
  CARRAY_index=find(strcmp("CARRAY",networkName));
  CARRAY_stationNumber=length(CARRAY_index);


  CARRAY_x = station_x(CARRAY_index);
  CARRAY_z = station_z(CARRAY_index);

  CARRAY=[];

  for nStation = 1:CARRAY_stationNumber
    signal = dlmread([signal_folder networkName{CARRAY_index(nStation)} '.' stationName{CARRAY_index(nStation)} band],'',startRowNumber,startColumnNumber);
    CARRAY = [CARRAY signal((1:resample_rate:end))];
  end

 %polar_response = transpose(max(abs(CARRAY)));
 %polar_response = polar_response/max(polar_response)
 %polar_response = 20*log10(polar_response);

 polar_response = octavePSD([t(1:resample_rate:end) CARRAY],f0);
 polar_response = transpose(polar_response);
 polar_response = polar_response - max(polar_response);

 polar_response = [rad2deg(cart2pol([CARRAY_x CARRAY_z])) polar_response];
 dlmwrite('../backup/polar_response',polar_response,' ');
end

%------------------------------------
