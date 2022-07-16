function [xmin ymin zmin xmax ymax zmax dx dy dz dielecctric_constant piezoelectric_constant elastic_constant density]=generate_piezomaterial_parameters()

meshInformation_file ='../backup/meshInformation';

[xmin_status xmin] = system(['grep xmin ' meshInformation_file ' | cut -d = -f 2']);
xmin = str2num(xmin);
[xmax_status xmax] = system(['grep xmax ' meshInformation_file ' | cut -d = -f 2']);
xmax = str2num(xmax);

[ymin_status ymin] = system(['grep ymin ' meshInformation_file ' | cut -d = -f 2']);
ymin = str2num(ymin);
[ymax_status ymax] = system(['grep ymax ' meshInformation_file ' | cut -d = -f 2']);
ymax = str2num(ymax);

[zmin_status zmin] = system(['grep zmin ' meshInformation_file ' | cut -d = -f 2']);
zmin = str2num(zmin);
[zmax_status zmax] = system(['grep zmax ' meshInformation_file ' | cut -d = -f 2']);
zmax = str2num(zmax);

[dx_status dx] = system(['grep dx ' meshInformation_file ' | cut -d = -f 2']);
dx = str2num(dx);

[dy_status dy] = system(['grep dy ' meshInformation_file ' | cut -d = -f 2']);
dy = str2num(dy);

[dz_status dz] = system(['grep dz ' meshInformation_file ' | cut -d = -f 2']);
dz = str2num(dz);

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

density = 4650;
if ~issymmetric(elastic_constant)
  error(['The elastic contant matrix is not symmetric!'])
end
