#!/bin/bash
source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
conda activate gmt6

#module load gmt
rm -f gmt.conf
rm -f gmt.history

gmt gmtset MAP_FRAME_AXES WeSn
gmt gmtset MAP_FRAME_TYPE plain
#gmt gmtset MAP_FRAME_PEN thick
#gmt gmtset MAP_TICK_PEN thick
#gmt gmtset MAP_TICK_LENGTH_PRIMARY -3p
#gmt gmtset MAP_DEGREE_SYMBOL none
#gmt gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.0i
#gmt gmtset MAP_GRID_CROSS_SIZE_SECONDARY 0.0i
#gmt gmtset MAP_GRID_PEN_PRIMARY thin,black
#gmt gmtset MAP_GRID_PEN_SECONDARY thin,black
gmt gmtset MAP_ORIGIN_X 100p
gmt gmtset MAP_ORIGIN_Y 100p
#gmt gmtset FORMAT_GEO_OUT +D
gmt gmtset COLOR_NAN 255/255/255
gmt gmtset COLOR_FOREGROUND 255/255/255
gmt gmtset COLOR_BACKGROUND 0/0/0
gmt gmtset FONT 12p,Helvetica,black
#gmt gmtset FONT 9p,Times-Roman,black
#gmt gmtset PS_MEDIA custom_2.8ix2.8i
gmt gmtset PS_MEDIA letter
gmt gmtset PS_PAGE_ORIENTATION portrait
#gmt gmtset GMT_VERBOSE d


backupfolder=../backup/
figfolder=../figures/
mkdir -p $figfolder

name=bodyforceField
originalxyz=$backupfolder/$name
unit_axis=0.000001
width=2.2

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`gmt gmtinfo $originalxyz -C | awk -v unit_axis="$unit_axis" '{print $1/unit_axis}'`
xmax=`gmt gmtinfo $originalxyz -C | awk -v unit_axis="$unit_axis" '{print $2/unit_axis}'`
zmin=`gmt gmtinfo $originalxyz -C | awk -v unit_axis="$unit_axis" '{print $3/unit_axis}'`
zmax=`gmt gmtinfo $originalxyz -C | awk -v unit_axis="$unit_axis" '{print $4/unit_axis}'`
#zmax=`echo 0.0 | bc -l`

height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
region=$xmin/$xmax/$zmin/$zmax

nx=`grep nx $backupfolder/meshInformation | cut -d = -f 2`
inc=`echo "($xmax - $xmin)/$nx" | bc -l`

colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
#--------------------------------------------------
grd=$backupfolder$name\.nc

bodyforce_xgrd=$backupfolder/bodyforce_x.nc
bodyforce_zgrd=$backupfolder/bodyforce_z.nc


bodyforce_min=`gmt gmtinfo $originalxyz -C | awk '{print $5}'`
bodyforce_max=`gmt gmtinfo $originalxyz -C | awk '{print $6}'`

unit_bodyforce=10000000000000
#unit_bodyforce=$bodyforce_max
lowerLimit=0
upperLimit=1
#lowerLimit=`echo "$bodyforce_min/$unit_bodyforce" | bc -l`
#upperLimit=`echo "$bodyforce_max/$unit_bodyforce" | bc -l`
#lowerLimit=`echo "$bodyforce_min" | awk -v unit_bodyforce="$unit_bodyforce" '{print $1/unit_bodyforce}'`
#upperLimit=`echo "$bodyforce_max" | awk -v unit_bodyforce="$unit_bodyforce" '{print $1/unit_bodyforce}'`

cpt=$backupfolder$name\.cpt
gmt makecpt -CGMT_hot.cpt -T$lowerLimit/$upperLimit -Iz > $cpt

gmt psbasemap -R$region -J$projection  -Bx10f5+l"X (10@+-6@+m) " -By10f5+l"Z (10@+-6@+m)" -K > $ps #-L+yt -Ggray 
awk -v unit_axis="$unit_axis" -v unit_bodyforce="$unit_bodyforce" '{print $1/unit_axis, $2/unit_axis, $3/unit_bodyforce}' $originalxyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$grd
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps

lowerLimit=-1
upperLimit=1
unit_bodyforce=$bodyforce_max
awk -v unit_axis="$unit_axis" -v unit_bodyforce="$unit_bodyforce" '{print $1/unit_axis, $2/unit_axis, $5/unit_bodyforce}' $originalxyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$bodyforce_xgrd
awk -v unit_axis="$unit_axis" -v unit_bodyforce="$unit_bodyforce" '{print $1/unit_axis, $2/unit_axis, $6/unit_bodyforce}' $originalxyz | gmt blockmean -R -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R -I$inc -G$bodyforce_zgrd

gmt grdvector $bodyforce_xgrd $bodyforce_zgrd -Ix2 -J  -Q0.1i+eAl+n0.25i+h0.1 -W1p -S10i -N -O -K >> $ps


awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupfolder/positive_finger | gmt psxy -J -R -Ss0.005i -Gred -N -O -K >> $ps
awk -v unit_axis="$unit_axis" '{print $1/unit_axis, $2/unit_axis}' $backupfolder/negative_finger | gmt psxy -J -R -Ss0.005i -Ggreen -N -O -K >> $ps

#gmt psscale -Dx$domain -C$cpt -Bxa1f0.5 -By+l"10@+13@+N/m@+3@+" -O >> $ps
gmt psscale -Dx$domain -C$cpt -Bxa1f0.5 -By+l"10@+13@+N/m@+2@+" -O >> $ps

rm -f $cpt $grd $bodyforce_xgrd $bodyforce_zgrd

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
rm -f $cpt $grd


#-----------------------------------------------------
rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
