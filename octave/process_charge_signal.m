#!/usr/bin/env octave

clear all
close all
clc

charge9 = dlmread('../backup/charge_crossFieldModel/charge_9_pairs','');
charge49 = dlmread('../backup/charge_crossFieldModel/charge_49_pairs','');
charge99 = dlmread('../backup/charge_crossFieldModel/charge_99_pairs','');
charge= [charge9 charge49(:,2) charge99(:,2)];
%voltage = dlmread(['../backup/sourceTimeFunction'],'');
voltage = dlmread(['../backup/charge_crossFieldModel/sourceTimeFunction'],'');

if rows(charge) != rows(voltage)
  error('the charge and voltage are not equal length!')
end
t = voltage(:,1);
%timeIndex =  find(t<=10e-8); 
%charge = charge(timeIndex,:);  
%voltage = voltage(timeIndex,:); 
%whos charge 

voltage_spectrum = trace2spectrum(voltage);
charge_spectrum = trace2spectrum(charge);
f = voltage_spectrum(:,1);
admittance = -i*2*pi*f.*charge_spectrum(:,2:end)./voltage_spectrum(:,2:end);
freqIndex = find(f>0.5e9&f<1.5e9);
f = f(freqIndex);
admittance = admittance(freqIndex,:);
conductance = real(admittance);
susceptance = imag(admittance);

[M,I] = max(conductance(:,3));
conductance_peak_frequency = f(I)
[M1,I1] = max(susceptance(:,3));
[M2,I2] = min(susceptance(:,3));
susceptance_peak_frequency = f([I1 I2])

conductance = [f conductance./max(abs(conductance))];
susceptance = [f susceptance./max(abs(susceptance))];

dlmwrite('../backup/conductance',conductance,' ');
dlmwrite('../backup/susceptance',susceptance,' ');

admittance_angle = [f rad2deg(angle(admittance))];

admittance_abs = [f 20*log10(abs(admittance)./max(abs(admittance)))];
%min(admittance_abs(:,2:end))
%max(admittance_abs(:,2:end))
dlmwrite('../backup/admittance_abs',admittance_abs,' ');
dlmwrite('../backup/admittance_angle',admittance_angle,' ');
