#!/usr/bin/env bash
source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
conda activate gmt6
#--------------------------------------------------------------------
name=$1
unit=$2
scale=$3
label=$4

backupFolder=../backup/
DATAFolder=../DATA/
figFolder=../figures/
mkdir -p $figFolder
fig=$figFolder$name
originalxyz=$backupFolder$name
grd=$backupFolder$name\.nc
xgrd=$backupFolder$name_x\.nc
zgrd=$backupFolder$name_z\.nc

column_number=`head -n 1 $originalxyz | awk '{print NF}'`

xmin=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $1/unit}'`
xmax=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $2/unit}'`
zmin=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $3/unit}'`
zmax=`gmt gmtinfo $originalxyz -C | awk -v unit="$unit" '{print $4/unit}'`

width=2.2
height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
region=$xmin/$xmax/$zmin/$zmax

inc=`grep step $DATAFolder\Par_file_PIEZO | cut -d = -f 2 | awk -v unit="$unit" '{print $1/unit}'`

colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i

#--------------------------------------------------------------------

amplitude_min=`gmt gmtinfo $originalxyz -C | awk '{print $5}'`
amplitude_max=`gmt gmtinfo $originalxyz -C | awk '{print $6}'`

scalarLowerLimit=0
scalarUpperLimit=1
vectorLowerLimit=-1
vectorUpperLimit=1

awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $3/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$scalarLowerLimit -Lu$scalarUpperLimit -R$region -I$inc -G$grd

if [ $column_number -eq 3 ]
then
cpt=GMT_seis.cpt
elif [ $column_number -eq 6 ]
then
cpt=GMT_hot.cpt
#awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $5/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$xgrd
#awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $6/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$zgrd
awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $5/scale}' $originalxyz | gmt surface -R$region -I$inc -G$xgrd
awk -v unit="$unit" -v scale="$scale" '{print $1/unit, $2/unit, $6/scale}' $originalxyz | gmt surface -R$region -I$inc -G$zgrd
fi

#-----------------------------------------------------
gmt begin $fig pdf
gmt makecpt -C$cpt -T$scalarLowerLimit/$scalarUpperLimit

gmt basemap -R$region -J$projection -BWeSn -Bx10f5+l"X ($unit\m) " -By10f5+l"Z ($unit\m)"
gmt grdimage $grd

if [ $column_number -eq 6 ]
then
gmt grdvector $xgrd $zgrd -Ix1 -J$projection -Q0.1i+eAl+n0.25i+h0.1 -W1p -S10i -N 
fi

gmt colorbar -Dx$domain -Bxa1f0.5 -By+l"$scale$label"

awk -v unit="$unit" '{print $1/unit, $2/unit}' $backupFolder/positive_finger | gmt plot -Ss0.005i -Gred -N
awk -v unit="$unit" '{print $1/unit, $2/unit}' $backupFolder/negative_finger | gmt plot -Ss0.005i -Ggreen -N

gmt end
rm -f $grd $xgrd $zgrd
#-----------------------------------------------------
rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
