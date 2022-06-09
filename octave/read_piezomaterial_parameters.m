function [xmin xmax ymin ymax zmin zmax step dielecctric_constant piezoelectric_constant elastic_constant]=read_piezomaterial_parameters()

Par_file_PIEZO ='../DATA/Par_file_PIEZO';

[xmin_status xmin] = system(['grep xmin ' Par_file_PIEZO ' | cut -d = -f 2']);
xmin = str2num(xmin);
[xmax_status xmax] = system(['grep xmax ' Par_file_PIEZO ' | cut -d = -f 2']);
xmax = str2num(xmax);

[ymin_status ymin] = system(['grep ymin ' Par_file_PIEZO ' | cut -d = -f 2']);
ymin = str2num(ymin);
[ymax_status ymax] = system(['grep ymax ' Par_file_PIEZO ' | cut -d = -f 2']);
ymax = str2num(ymax);

[zmin_status zmin] = system(['grep zmin ' Par_file_PIEZO ' | cut -d = -f 2']);
zmin = str2num(zmin);
[zmax_status zmax] = system(['grep zmax ' Par_file_PIEZO ' | cut -d = -f 2']);
zmax = str2num(zmax);

[step_status step] = system(['grep step ' Par_file_PIEZO ' | cut -d = -f 2']);
step = str2num(step);

%x = [xmin:step:xmax];
%z = [zmin:step:zmax];

dielecctric_constant=...
[85.2    0    0;
    0 85.2    0;
    0    0 28.7].*8.55.*10.^(-12);

piezoelectric_constant=...
[    0    0   0    0 3.83 -2.37; ...
 -2.37 2.37   0 3.83    0     0; ...
  0.23 0.23 1.3    0    0     0];

elastic_constant=...
[2.030  0.573 0.752  0.085     0     0; ...
 0.573  2.030 0.752 -0.085     0     0; ...
 0.752  0.752 2.424      0     0     0; ...
 0.085 -0.085     0  0.595     0     0; ...
     0      0     0      0 0.595 0.085; ...
     0      0     0      0 0.085 0.728].*10^(11); 
if ~issymmetric(elastic_constant)
  error(['The elastic contant matrix is not symmetric!'])
end

%dielecctric_constant
%piezoelectric_constant
%elastic_constant
