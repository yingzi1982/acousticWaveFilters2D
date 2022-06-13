#!/bin/bash
source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
conda activate gmt6
#--------------------------------------------------------------------
rm -f gmt.conf
rm -f gmt.history
gmt gmtset MAP_FRAME_AXES WeSn


name=$1
unit=$2
scale=$3
label=$4

backupFolder=../backup/
DATAFolder=../DATA/
figFolder=../figures/
fig=$figFolder$name
mkdir -p $figFolder
originalxyz=$backupFolder$name
grd=$backupFolder$name\.nc
xgrd=$backupFolder$name_x\.nc
zgrd=$backupFolder$name_z\.nc

column_number=`head -n 1 $originalxyz | awk '{print NF}'`
if [ $column_number -eq 3 ]
then
#echo 'Plotting scalar field of data at' $originalxyz
cpt=GMT_seis.cpt
lowerLimit=0
upperLimit=1
elif [ $column_number -eq 6 ]
then
#echo 'Plotting vector field of data at' $originalxyz
cpt=GMT_hot.cpt
lowerLimit=0
upperLimit=1
fi

xmin=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $1/unit}'`
xmax=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $2/unit}'`
zmin=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $3/unit}'`
zmax=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $4/unit}'`

width=2.2
height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
region=$xmin/$xmax/$zmin/$zmax

inc=`grep step $DATAFolder\Par_file_PIEZO | cut -d = -f 2 | awk -v unit="$unit" '{print $1/unit}'`

#colorbar_width=$height
#colorbar_height=0.16
#colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
#colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
#domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i

#--------------------------------------------------------------------

field_min=`gmt gmtinfo $originalxyz -C | awk '{print $5}'`
field_max=`gmt gmtinfo $originalxyz -C | awk '{print $6}'`

gmt begin $fig pdf
#gmt set MAP_GRID_PEN_PRIMARY thinnest,-

gmt makecpt -C$cpt -T$lowerLimit/$upperLimit -Iz

gmt psbasemap -R$region -J$projection  -Bx10f5+l"X ($unit\m) " -By10f5+l"Z ($unit\m)"
awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $3/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd
gmt grdimage $grd -C$cpt

if [ $column_number -eq 6 ]
then
awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $5/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$xgrd
awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $6/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$zgrd
gmt grdvector $bodyforce_xgrd $bodyforce_zgrd -Ix1 -J  -Q0.1i+eAl+n0.25i+h0.1 -W1p -S10i -N 
fi

awk -v unit="$unit" '{print $1/unit, $2/unit}' $backupFolder/positive_finger | gmt psxy -Ss0.005i -Gred -N
awk -v unit="$unit" '{print $1/unit, $2/unit}' $backupFolder/negative_finger | gmt psxy -Ss0.005i -Ggreen -N

#gmt psscale -Dx$domain -C$cpt -Bxa1f0.5 -By+l"10@+13@+N/m@+2@+"

gmt end
rm -f $grd $xgrd $zgrd
exit



#-----------------------------------------------------
rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
