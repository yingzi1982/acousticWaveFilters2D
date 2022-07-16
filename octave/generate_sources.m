#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  filter_dimension = arg_list{1};
else
  error('Please input filter dimension.');
end

[ATTENUATION_f0_REFERENCEStatus ATTENUATION_f0_REFERENCE] = system('grep ^ATTENUATION_f0_REFERENCE ../backup/Par_file.part | cut -d = -f 2');
ATTENUATION_f0_REFERENCE = str2num(ATTENUATION_f0_REFERENCE);
f0 = ATTENUATION_f0_REFERENCE;

[nt_status nt] = system('grep ^NSTEP\  ../backup/Par_file.part | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file.part | cut -d = -f 2');
dt = str2num(dt);
fs=1/dt;
t =transpose([0:nt-1]*dt);

signal_type='ricker';
switch signal_type
case 'ricker'
[t_cut s_cut] = ricker(f0, dt);

otherwise
error('Wrong signal type!')
end

sourceTimeFunction= [t_cut s_cut];
save("-ascii",['../backup/sourceTimeFunction'],'sourceTimeFunction')

nfft = 2^nextpow2(length(t_cut));
S_cut = fft(s_cut,nfft);

Fs=1/dt;
f = transpose(Fs*(0:(nfft/2))/nfft);
%PSD = 2*abs(S_cut(1:nfft/2+1)/nfft).^2;
%PSD = 10*log10(PSD);
%sourceFrequencySpetrum =[f,PSD];
S_spectrum = 2*abs(S_cut(1:nfft/2+1)/nfft);
sourceFrequencySpetrum =[f,S_spectrum];
save("-ascii",['../backup/sourceFrequencySpetrum'],'sourceFrequencySpetrum')

s = zeros(nt,1);
s(1:length(s_cut)) = s_cut;

%------------------------------------

switch filter_dimension 
case '2D'
bodyforce=load('../backup/bodyforce');

bodyforce_x = bodyforce(:,1);
bodyforce_z = bodyforce(:,2);
bodyforce_rho = bodyforce(:,3);
bodyforce_theta = bodyforce(:,4);

selection_index = find(bodyforce_rho/max(bodyforce_rho)>=.05);

source_number = length(selection_index);
source_size = size(selection_index);

xs = bodyforce_x(selection_index);
zs = bodyforce_z(selection_index);

anglesource = rad2deg(bodyforce_theta(selection_index) - pi/2);
factor = bodyforce_rho(selection_index);

source_surf                     = [repmat({'.false.'},1,source_number)];
source_type                     = [1]*ones(source_size);
time_function_type              = [8]*ones(source_size);
name_of_source_file             = [repmat({'DATA/STF'},1,source_number)];
burst_band_width                = [0.0]*ones(source_size);
f0                              = [f0]*ones(source_size);
tshift                          = [0.0]*ones(source_size);
Mxx                             = [1.0]*ones(source_size);
Mzz                             = [1.0]*ones(source_size); 
Mxz                             = [0.0]*ones(source_size);
vx                              = [0]*ones(source_size);
vz                              = [0]*ones(source_size);

%source = [xs zs];
%save('-ascii','../backup/source','source');

%delete ../DATA/SOURCE
%delete ../DATA/STF*

fileID = fopen(['../DATA/SOURCE'],'w');
for nSOURCE = [1:source_number]
  fprintf(fileID, 'source_surf        = %s\n', source_surf{nSOURCE})
  fprintf(fileID, 'xs                 = %g\n', xs(nSOURCE))
  fprintf(fileID, 'zs                 = %g\n', zs(nSOURCE))
  fprintf(fileID, 'source_type        = %i\n', source_type(nSOURCE))
  fprintf(fileID, 'time_function_type = %i\n', time_function_type(nSOURCE))
  stf_name = [name_of_source_file{nSOURCE} '_' int2str(nSOURCE)];
  fprintf(fileID, 'name_of_source_file= %s\n', stf_name)
  fprintf(fileID, 'burst_band_width   = %f\n', burst_band_width(nSOURCE))
  fprintf(fileID, 'f0                 = %g\n', f0(nSOURCE))
  fprintf(fileID, 'tshift             = %f\n', tshift(nSOURCE))
  fprintf(fileID, 'anglesource        = %f\n', anglesource(nSOURCE))
  fprintf(fileID, 'Mxx                = %f\n', Mxx(nSOURCE))
  fprintf(fileID, 'Mzz                = %f\n', Mzz(nSOURCE))
  fprintf(fileID, 'Mxz                = %f\n', Mxz(nSOURCE))
  fprintf(fileID, 'factor             = %g\n', factor(nSOURCE))
  fprintf(fileID, 'vx                 = %f\n', vx(nSOURCE))
  fprintf(fileID, 'vz                 = %f\n', vz(nSOURCE))
  fprintf(fileID, '#\n')
  dlmwrite(['../' stf_name],[t s],' ');
  %stf_fileID = fopen(stf_name,'w');
  %for i = 1:nt
  %  fprintf(stf_fileID, '%f %f\n', t(i), s(i))
  %end
  %fclose(stf_fileID);
end
fclose(fileID);

case '3D'
otherwise
error('Wrong filter dimension!')
end
