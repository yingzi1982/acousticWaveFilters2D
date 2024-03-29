#!/usr/bin/env octave

clear all
close all
clc

[xmin xmax zmin zmax step dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters;
dx=step;
dz=step;
nx = round((xmax-xmin)/dx+1);
nz = round((zmax-zmin)/dz+1);
x = linspace(xmin,xmax,nx);
z = linspace(zmin,zmax,nz);
[X Z] = ndgrid (x,z);
%---------------------------------
% SAW
finger_z = zmax;
unit_length = 1.0E-6;
finger_width = 1*unit_length;
finger_gap = 1*unit_length;
finger_period = 2*(finger_width+finger_gap);
period_width = (finger_width +finger_gap)*2; % positive+gap+negative+gap
single_negative_finger_x = [-finger_gap/2-finger_width:dx:-finger_gap/2];
single_positive_finger_x = [ finger_gap/2:dx:finger_width+finger_gap/2];

negative_finger_x = [];
positive_finger_x = [];
fingerNumber=0;
for i = 0
%for i = -3:3
   fingerNumber = fingerNumber+1;
   negative_finger_x = [negative_finger_x single_negative_finger_x+i*period_width];
   positive_finger_x = [positive_finger_x single_positive_finger_x+i*period_width];
end
disp([ "Finger Number = " int2str(fingerNumber)]);

[negative_finger_x negative_finger_x_index]=findNearest(x,negative_finger_x);
[positive_finger_x positive_finger_x_index]=findNearest(x,positive_finger_x);

negative_finger_z = ones(size(negative_finger_x))*finger_z;
positive_finger_z = ones(size(positive_finger_x))*finger_z;

[negative_finger_z negative_finger_z_index]=findNearest(z,negative_finger_z);
[positive_finger_z positive_finger_z_index]=findNearest(z,positive_finger_z);

positive_finger = [positive_finger_x' positive_finger_z'];
negative_finger = [negative_finger_x' negative_finger_z'];
dlmwrite('../backup/positive_finger',positive_finger,' ');
dlmwrite('../backup/negative_finger',negative_finger,' ');
positive_finger_V = 1;
negative_finger_V = 0;
%negative_finger_V = 0;
%---------------------------------

V = zeros(size(X));

norm_V = 0;
norm_residual = 0.000001;
iterationNumber=200000;
%iterationNumber=20000;
for i = 1:iterationNumber
%fixed potential
  V(positive_finger_x_index,positive_finger_z_index) = positive_finger_V;
  V(negative_finger_x_index,negative_finger_z_index) = negative_finger_V;

% update potential
  V(2:end-1,2:end-1) = (V(1:end-2,2:end-1) + V(3:end,2:end-1) + V(2:end-1,1:end-2) + V(2:end-1,3:end))/4; % inner domain

  V(1,2:end-1) = (V(1,3:end) + V(1,1:end-2) + V(2,2:end-1))/3; % left edge
  V(end,2:end-1) = (V(end,3:end) + V(end,1:end-2) + V(end-1,2:end-1))/3; % right edge
  V(2:end-1,1) = (V(1:end-2,1) + V(3:end,1) + V(2:end-1,2))/3; % bottom edge
  V(2:end-1,end) = (V(1:end-2,end) + V(3:end,end) + V(2:end-1,end-1))/3; % top edge

  V(1,1) = (V(1,2) + V(2,1))/2; % left bottom corner
  V(1,end) = (V(2,end) + V(1,end-1))/2; % left top corner
  V(end,1) = (V(end-1,1) + V(end,2))/2; % right bottom corner
  V(end,end) = (V(end-1,end) + V(end,end-1))/2; % right top corner

  norm_V_new = norm(V);
  if (norm_V_new - norm_V)/norm_V_new < norm_residual
    %break;
  else
    norm_V = norm_V_new;
  end

end
disp([ "Iteration Number = " int2str(i)]);
%length(find(V>0.5))


X = permute(X,[2 1]); 
Z = permute(Z,[2 1]);  
V = permute(V,[2 1]);  

[E_x E_z] = gradient(V,dx,dz);
E_x = -E_x;
E_z = -E_z;

[E_theta,E_rho] = cart2pol(E_x,E_z);

electricFields=[reshape(X,[],1) reshape(Z,[],1) [reshape(V,[],1)]  reshape(E_rho,[],1) reshape(E_theta,[],1) [reshape(E_x,[],1) reshape(E_z,[],1)]];

dlmwrite('../backup/electricFields',electricFields,' ');
