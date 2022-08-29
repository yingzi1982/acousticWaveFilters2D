#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  filter_type  = arg_list{1};
  filter_dimension = arg_list{2};
else
  error('Please input filter type and dimension.');
end

[piezo]=generate_piezomaterial_parameters(filter_dimension);
x = piezo.x;
y = piezo.y;
z = piezo.z;

dx = piezo.dx;
zmax = piezo.zmax;
%---------------------------------

unit_length = 1.0E-6;
switch filter_type
case 'SAW'
finger_pair_number=20;
%finger_pair_number=7;
%finger_pair_number=1;
finger_width = 1*unit_length;
finger_gap = 1*unit_length;
finger_period = 2*(finger_width+finger_gap);
period_width = (finger_width +finger_gap)*2; % positive+gap+negative+gap
  switch filter_dimension
  case '2D'

  single_negative_finger_x = [-finger_gap/2-finger_width:dx:-finger_gap/2];
  single_positive_finger_x = [ finger_gap/2:dx:finger_width+finger_gap/2];

  negative_finger_x = [];
  positive_finger_x = [];
  for i = -(finger_pair_number-1)/2:(finger_pair_number-1)/2
  negative_finger_x = [negative_finger_x single_negative_finger_x+i*period_width];
  positive_finger_x = [positive_finger_x single_positive_finger_x+i*period_width];
  end

  [negative_finger_x negative_finger_x_index]=findNearest(x,negative_finger_x);
  [positive_finger_x positive_finger_x_index]=findNearest(x,positive_finger_x);

  finger_z = zmax;
  negative_finger_z = ones(size(negative_finger_x))*finger_z;
  positive_finger_z = ones(size(positive_finger_x))*finger_z;

  [negative_finger_z negative_finger_z_index]=findNearest(z,negative_finger_z);
  [positive_finger_z positive_finger_z_index]=findNearest(z,positive_finger_z);

  positive_finger = [positive_finger_x' positive_finger_z'];
  negative_finger = [negative_finger_x' negative_finger_z'];

  positive_finger_index = [];
  negative_finger_index = [];
  case '3D'
  otherwise
  error('Wrong filter dimension!')
  end
case 'BAW'
  switch dimension
  case '2D'
  case '3D'
  otherwise
  error('Wrong filter dimension!')
  end
otherwise
error('Wrong filter type!')
end

dlmwrite('../backup/positive_finger',positive_finger,' ');
dlmwrite('../backup/negative_finger',negative_finger,' ');
