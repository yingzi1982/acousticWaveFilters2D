#!/usr/bin/env octave

clear all
close all
clc

charge = dlmread('../backup/charge','');
voltage = dlmread(['../backup/sourceTimeFunction'],'');

whos charge 

if rows(charge) != rows(voltage)
  error('the charge and voltage are not equal length!')
end
t = charge(:,1);
timeIndex =  find(t<=10e-8); 
charge = charge(timeIndex,:);  
voltage = voltage(timeIndex,:); 
whos charge 

voltage_spectrum = trace2spectrum(voltage);
charge_spectrum = trace2spectrum(charge);
f = voltage_spectrum(:,1);
admittance = -i*2*pi*f.*charge_spectrum(:,2)./voltage_spectrum(:,2);
[M,I] = max(imag(admittance))
f(I)
freqIndex = find(f>0.5e9&f<1.5e9);
admittance = [abs(admittance) real(admittance) imag(admittance)];

min(admittance(freqIndex))
max(admittance(freqIndex))

admittance = [f, admittance];
dlmwrite('../backup/admittance',admittance,' ');
