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

[xminStatus xmin] = system('grep xmin ../backup/Par_file.part | cut -d = -f 2');
xmin = str2num(xmin);

[xmaxStatus xmax] = system('grep xmax ../backup/Par_file.part | cut -d = -f 2');
xmax = str2num(xmax);

[nxStatus nx] = system('grep nx ../backup/Par_file.part | cut -d = -f 2');
nx = str2num(nx);
xNumber = nx + 1;

dx = (xmax - xmin)/nx;
x=linspace(xmin,xmax,xNumber);
dz = dx;
%---------------------------------

unit_length = 1.0E-6;

switch filter_type
case 'SAW'

finger_z_min = 0.0*unit_length;
%finger_z_max = 0.2*unit_length;
finger_z_max = 0.0*unit_length;

finger_z = [finger_z_min:dz:finger_z_max];

%finger_pair_number=17;
finger_pair_number=19;
%finger_pair_number=1;
dlmwrite('../backup/finger_pair_number',finger_pair_number,' ');
finger_width = 1*unit_length;
finger_gap = 1*unit_length;
period_width = (finger_width +finger_gap)*2; % positive+gap+negative+gap
  switch filter_dimension
  case '2D'

  single_positive_finger_x = [ 0:dx:finger_width-dx];
  single_negative_finger_x = single_positive_finger_x - period_width/2;

  positive_finger_x = [];
  negative_finger_x = [];

  for i = -floor((finger_pair_number-1)/2):floor((finger_pair_number-1)/2)
  positive_finger_x = [positive_finger_x single_positive_finger_x+i*period_width];
  negative_finger_x = [negative_finger_x single_negative_finger_x+i*period_width];
  end

  positive_finger_contact_interface = [transpose(positive_finger_x) transpose(finger_z_min*ones(size(positive_finger_x)))];
  negative_finger_contact_interface = [transpose(negative_finger_x) transpose(finger_z_min*ones(size(negative_finger_x)))];
  
  [positive_finger_grid_x positive_finger_grid_z] = meshgrid(positive_finger_x,finger_z);
  [negative_finger_grid_x negative_finger_grid_z] = meshgrid(negative_finger_x,finger_z);

  positive_finger_grid = [reshape(positive_finger_grid_x,[],1) reshape(positive_finger_grid_z,[],1)];
  negative_finger_grid = [reshape(negative_finger_grid_x,[],1) reshape(negative_finger_grid_z,[],1)];

 [positive_finger_x positive_finger_x_index]=findNearest(x,positive_finger_x);
  positive_finger_z_min = ones(size(x))*finger_z_min;
  positive_finger_z_max = positive_finger_z_min;
  positive_finger_z_max(positive_finger_x_index) = finger_z_max;

 [negative_finger_x negative_finger_x_index]=findNearest(x,negative_finger_x);
  negative_finger_z_min = ones(size(x))*finger_z_min;
  negative_finger_z_max = negative_finger_z_min;
  negative_finger_z_max(negative_finger_x_index) = finger_z_max;
  
  total_finger_z_min = ones(size(x))*finger_z_min;
  total_finger_z_max = total_finger_z_min;
  total_finger_z_max([negative_finger_x_index positive_finger_x_index]) = finger_z_max;

  positive_finger_interfaces = [x' positive_finger_z_min' positive_finger_z_max'];
  negative_finger_interfaces = [x' negative_finger_z_min' negative_finger_z_max'];
  
  total_finger_interfaces = [x' total_finger_z_min' total_finger_z_max'];

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

dlmwrite('../backup/positive_finger_contact_interface',positive_finger_contact_interface,' ');
dlmwrite('../backup/negative_finger_contact_interface',negative_finger_contact_interface,' ');

dlmwrite('../backup/positive_finger_interfaces',positive_finger_interfaces,' ');
dlmwrite('../backup/negative_finger_interfaces',negative_finger_interfaces,' ');
dlmwrite('../backup/total_finger_interfaces',total_finger_interfaces,' ');

dlmwrite('../backup/positive_finger_grid',positive_finger_grid,' ');
dlmwrite('../backup/negative_finger_grid',negative_finger_grid,' ');
