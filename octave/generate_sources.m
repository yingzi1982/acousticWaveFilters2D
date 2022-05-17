#!/usr/bin/env octave

clear all
close all
clc

generate_virtual_airgun_source;

[ATTENUATION_f0_REFERENCEStatus ATTENUATION_f0_REFERENCE] = system('grep ^ATTENUATION_f0_REFERENCE ../backup/Par_file.part | cut -d = -f 2');
ATTENUATION_f0_REFERENCE = str2num(ATTENUATION_f0_REFERENCE);
f0 = ATTENUATION_f0_REFERENCE;

[nt_status nt] = system('grep ^NSTEP\  ../backup/Par_file.part | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file.part | cut -d = -f 2');
dt = str2num(dt);
fs=1/dt;
t =transpose([0:nt-1]*dt);

%signalType='quasiSingleFreq';
%signalType='ricker';
signalType='airgun';
%signalType='noise';
if strcmp(signalType,'ricker')
[t_cut s_cut] = ricker(f0, dt);
%s_cut = -cumsum(s_cut);
%s_cut(1)=0;
elseif strcmp(signalType,'airgun')
airgun_signal=load('../backup/virtualAirgunSourceTimeFunction');

t_airgun_signal = airgun_signal(:,1);
s_airgun_signal = airgun_signal(:,2);
dt_airgun_signal = t_airgun_signal(2)-t_airgun_signal(1);
t_cut = [t_airgun_signal(1):dt:t_airgun_signal(end)]';
s_cut = interp1(t_airgun_signal,s_airgun_signal,t_cut,'spline');

%fcuts = [1000 1100];
fcuts = [300 310];
mags = [1 0];
devs = [0.05 0.01];
filter_parameters=[fcuts;mags;devs];
save("-ascii",['../backup/filter_parameters'],'filter_parameters')
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
s_cut = filtfilt(hh,1,s_cut);

s_cut = s_cut - mean(s_cut);

halfWindowPointNumber=50;
hanningWindow=hanning(2*halfWindowPointNumber+1);
firstHalfHanningWindow=hanningWindow(1:halfWindowPointNumber+1);
lastHalfHanningWindow=hanningWindow(halfWindowPointNumber+1:end);

s_cut(1:halfWindowPointNumber+1) = s_cut(1:halfWindowPointNumber+1).*firstHalfHanningWindow;
s_cut(end-halfWindowPointNumber:end) = s_cut(end-halfWindowPointNumber:end).*lastHalfHanningWindow;

elseif strcmp(signalType,'noise')
t_cut = [0:dt:(nt-1)*dt]';
%s_cut = pinkNoise(nt)';
seed=82;
rand('seed',seed);
s_cut = randn(nt, 1);

[B,A] = oct3dsgn(f0,fs);
s_cut = filtfilt(B,A,s_cut);

stepNumber=round(1/f0/dt*2);
hanningWindow=hanning(2*stepNumber+1);
window=ones(nt,1);
window(1:stepNumber) = hanningWindow(1:stepNumber);
s_cut = s_cut.*window;
%s_cut_max = max(abs(s_cut));
%save("-ascii",['../backup/airgun_source_peak'],'s_cut_max')

elseif strcmp(signalType,'quasiSingleFreq')
t_cut = [0:dt:(nt-1)*dt]';
s_cut = sin(2*pi*f0*t_cut);
stepNumber=round(1/f0/dt*2);
hanningWindow=hanning(2*stepNumber+1);
window=ones(nt,1);
window(1:stepNumber) = hanningWindow(1:stepNumber);
s_cut = s_cut.*window;

end
%f_start_filter=100;
%f_end_filter=20000;
%Wn=[f_start_filter f_end_filter]*2/Fs;
%N = 3;
%[a,b] = butter(N,Wn);
%s = filtfilt(a,b,s);
%s=s.*hanning(length(s))

sourceTimeFunction= [t_cut s_cut];
save("-ascii",['../backup/sourceTimeFunction'],'sourceTimeFunction')

ref=0.1^6;

nfft = 2^nextpow2(length(t_cut));
S_cut = fft(s_cut/ref,nfft);

Fs=1/dt;
f = transpose(Fs*(0:(nfft/2))/nfft);
PSD = 2*abs(S_cut(1:nfft/2+1)/nfft).^2;
PSD = 10*log10(PSD);
sourceFrequencySpetrum =[f,PSD];
save("-ascii",['../backup/sourceFrequencySpetrum'],'sourceFrequencySpetrum')

octaveFreq=2.^[1:8]';
save("-ascii",['../backup/octaveFreq'],'octaveFreq')

octavePSD = octavePSD([t_cut s_cut/ref],octaveFreq);

octavePSD = [octaveFreq octavePSD];
save("-ascii",['../backup/sourceOctavePSD'],'octavePSD')

s = zeros(nt,1);
s(1:length(s_cut)) = s_cut;

%s = cumsum(s,2);
%s = s/max(s)
normalization_factor=1/67.24;
s = s*normalization_factor;

%source_element_distance = 1;
%source_element_number = 200;
%xs                              = transpose([1:source_element_number]*source_element_distance);
%xs = xs -mean(xs);
xs                              = [0];
source_depth= 7;
source_number = length(xs);
source_size = size(xs);

source_surf                     = [repmat({'.false.'},1,source_number)];
zs                              = [-source_depth]*ones(source_size);
source_type                     = [1]*ones(source_size);
time_function_type              = [8]*ones(source_size);
name_of_source_file             = [repmat({'DATA/STF'},1,source_number)];
burst_band_width                = [0.0]*ones(source_size);
f0                              = [f0]*ones(source_size);
tshift                          = [0.0]*ones(source_size);
anglesource                     = [0.0]*ones(source_size);
Mxx                             = [1.0]*ones(source_size);
Mzz                             = [1.0]*ones(source_size); 
Mxz                             = [0.0]*ones(source_size);
factor                          = [1.0]*ones(source_size);
%factor                          = [1/67.24]*ones(source_size); %point source
vx                          = [0]*ones(source_size);
vz                          = [0]*ones(source_size);

source = [xs zs];
save('-ascii','../backup/source','source');


fileID = fopen(['../DATA/SOURCE'],'w');
for nSOURCE = [1:source_number]
  fprintf(fileID, 'source_surf        = %s\n', source_surf{nSOURCE})
  fprintf(fileID, 'xs                 = %f\n', xs(nSOURCE))
  fprintf(fileID, 'zs                 = %f\n', zs(nSOURCE))
  fprintf(fileID, 'source_type        = %i\n', source_type(nSOURCE))
  fprintf(fileID, 'time_function_type = %i\n', time_function_type(nSOURCE))
  stf_name = [name_of_source_file{nSOURCE} '_' int2str(nSOURCE)];
  fprintf(fileID, 'name_of_source_file= %s\n', stf_name)
  fprintf(fileID, 'burst_band_width   = %f\n', burst_band_width(nSOURCE))
  fprintf(fileID, 'f0                 = %f\n', f0(nSOURCE))
  fprintf(fileID, 'tshift             = %f\n', tshift(nSOURCE))
  fprintf(fileID, 'anglesource        = %f\n', anglesource(nSOURCE))
  fprintf(fileID, 'Mxx                = %f\n', Mxx(nSOURCE))
  fprintf(fileID, 'Mzz                = %f\n', Mzz(nSOURCE))
  fprintf(fileID, 'Mxz                = %f\n', Mxz(nSOURCE))
  fprintf(fileID, 'factor             = %f\n', factor(nSOURCE))
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
