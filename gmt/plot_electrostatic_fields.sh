#!/bin/bash
module load gmt

#gmt clear all

backupFolder=../backup/
dataFolder=../DATA/
figFolder=../figures/

#mkdir -p $figFolder

name=electricFields
original_xyz=$backupFolder/$name
fig=$figFolder/$name

unit_axis=0.000001
xmin=`gmt gmtinfo $original_xyz -C | awk -v unit_axis="$unit_axis" '{print $1/unit_axis}'`
xmax=`gmt gmtinfo $original_xyz -C | awk -v unit_axis="$unit_axis" '{print $2/unit_axis}'`
zmin=`gmt gmtinfo $original_xyz -C | awk -v unit_axis="$unit_axis" '{print $3/unit_axis}'`
zmax=`gmt gmtinfo $original_xyz -C | awk -v unit_axis="$unit_axis" '{print $4/unit_axis}'`
#zmax=`echo 0.0 | bc -l`

nx=`grep nx $dataFolder/PIEZO | cut -d = -f 2`
inc=`echo "($xmax - $xmin)/$nx" | bc -l`

width=2.2
height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
region=$xmin/$xmax/$zmin/$zmax

gmt begin panels pdf
  gmt subplot begin 2x2 -Fs8c -M5p -A -SCb -SRl -R0/80/0/10
    gmt subplot set
    gmt basemap
    gmt subplot set
    gmt basemap
    gmt subplot set
    gmt basemap
    gmt subplot set
    gmt basemap
  gmt subplot end
gmt end show

gmt begin $fig pdf
  #gmt subplot begin 2x1 
  #gmt subplot set 0,0
  #gmt subplot set 1,0
  #gmt subplot end
gmt end
exit


colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
#--------------------------------------------------
grd=$backupFolder$name\.nc

Exgrd=$backupFolder/Ex.nc
Ezgrd=$backupFolder/Ez.nc


Emin=`gmt gmtinfo $original_xyz -C | awk '{print $7}'`
Emax=`gmt gmtinfo $original_xyz -C | awk '{print $8}'` #echo $Emin $Emax

unit_E=1000000
#unit_E=$Emax
lowerLimit=0
#upperLimit=1
#lowerLimit=`echo "$Emin/$unit_E" | bc -l`
upperLimit=`echo "$Emax/$unit_E" | bc -l`
cpt=$backupFolder$name\.cpt
gmt makecpt -Chot.cpt -T$lowerLimit/$upperLimit -Z -Iz > $cpt

gmt psbasemap -R$region -J$projection  -Bx10f5+l"X (10@+-6@+m) " -By10f5+l"Z (10@+-6@+m)" -K > $ps #-L+yt -Ggray 
awk -v unit_axis="$unit_axis" -v unit_E="$unit_E" '{print $1/unit_axis, $2/unit_axis, $4/unit_E}' $original_xyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$grd
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps

lowerLimit=-1
upperLimit=1
unit_E=$Emax
awk -v unit_axis="$unit_axis" -v unit_E="$unit_E" '{print $1/unit_axis, $2/unit_axis, $6/unit_E}' $original_xyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$Exgrd
awk -v unit_axis="$unit_axis" -v unit_E="$unit_E" '{print $1/unit_axis, $2/unit_axis, $7/unit_E}' $original_xyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$Ezgrd

gmt grdvector $Exgrd $Ezgrd -Ix5 -J  -Q0.1i+e+n0.25i+h0.5 -W1p -S10i -N -O -K >> $ps

awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupFolder/positive_finger | gmt psxy -J -R -Ss0.005i -Gred -N -O -K >> $ps
awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupFolder/negative_finger | gmt psxy -J -R -Ss0.005i -Ggreen -N -O -K >> $ps


gmt psscale -D$domain -C$cpt -Bxa1f0.5 -By+l"10@+6@+v/m" -O -K >> $ps

rm -f $cpt $grd $Exgrd $Ezgrd

#-----------------------------------------------------
name=potentialField

grd=$backupFolder$name\.nc

gmt gmtset MAP_FRAME_AXES wesn

Vmin=`gmt gmtinfo $original_xyz -C | awk '{print $5}'`
Vmax=`gmt gmtinfo $original_xyz -C | awk '{print $6}'`

lowerLimit=0
upperLimit=1
#lowerLimit=$Vmin
#upperLimit=$Vmax
cpt=$backupFolder$name\.cpt
gmt makecpt -Chot.cpt -T$lowerLimit/$upperLimit -Z -Iz > $cpt

gmt psbasemap -R$region -J$projection  -Bx10f5+l"X (10@+-6@+m) " -By10f5+l"Z (10@+-6@+m)" -Y$offset -O -K >> $ps #-L+yt -Ggray 
awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis, $3}' $original_xyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$grd
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps

awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupFolder/positive_finger | gmt psxy -J -R -Ss0.005i -Gred -N -O -K >> $ps
awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupFolder/negative_finger | gmt psxy -J -R -Ss0.005i -Ggreen -N -O -K >> $ps

gmt psscale -D$domain -C$cpt -Bxa1f0.5 -By+lv -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
rm -f $cpt $grd 
#-----------------------------------------------------
rm -f gmt.conf
rm -f gmt.history
module unload gmt
