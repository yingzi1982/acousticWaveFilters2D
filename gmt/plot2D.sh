#!/usr/bin/env bash
#module load gmt
source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
conda activate gmt6
#gmt defaults > gmt.conf
rm -f gmt.conf
rm -f gmt.history
#gmt set MAP_FRAME_TYPE plain
#gmt set MAP_FRAME_PEN thin
gmt set FONT 12p,Helvetica,black
#--------------------------------------------------------------------
name=${1}
type=${2}
cpt=${3}
scale=${4}
unit=${5}

xinc=${6}
xlabel=${7}
xscale=${8}
xunit=${9}

zinc=${10}
zlabel=${11}
zscale=${12}
zunit=${13}

backupFolder=../backup/
DATAFolder=../DATA/
figFolder=../figures/
mkdir -p $figFolder
fig=$figFolder$name\_$type

originalxyz=$backupFolder$name
grd=$backupFolder$name\.nc
xgrd=$backupFolder$name\_x.nc
zgrd=$backupFolder$name\_z.nc

xmin=`gmt info $originalxyz -C | awk -v xscale="$xscale" '{print $1/xscale}'`
xmax=`gmt info $originalxyz -C | awk -v xscale="$xscale" '{print $2/xscale}'`
zmin=`gmt info $originalxyz -C | awk -v zscale="$zscale" '{print $3/zscale}'`
zmax=`gmt info $originalxyz -C | awk -v zscale="$zscale" '{print $4/zscale}'`

width=2.2
height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
region=$xmin/$xmax/$zmin/$zmax

xinc=`echo $xinc | awk -v xscale="$xscale" '{print $1/xscale}'`
zinc=`echo $zinc | awk -v zscale="$zscale" '{print $1/zscale}'`
inc=$xinc/$zinc

colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
#--------------------------------------------------------------------

amplitude_min=`gmt info $originalxyz -C | awk '{print $5}'`
amplitude_max=`gmt info $originalxyz -C | awk '{print $6}'`

scalarLowerLimit=0
scalarUpperLimit=1
vectorLowerLimit=-1
vectorUpperLimit=1

if [ $type == 'S' ] || [ $type == 'V1' ]
then
awk -v xscale="$xscale" -v zscale="$zscale" -v scale="$scale" '{print $1/xscale, $2/zscale, $3/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$scalarLowerLimit -Lu$scalarUpperLimit -R$region -I$inc -G$grd
fi

if [ $type == 'V1' ]
then
awk -v xscale="$xscale" -v zscale="$zscale" -v scale="$amplitude_max" '{print $1/xscale, $2/xscale, $5/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$xgrd
awk -v xscale="$xscale" -v zscale="$zscale" -v scale="$amplitude_max" '{print $1/xscale, $2/xscale, $6/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$zgrd
fi

if [ $type == 'V2' ]
then
awk -v xscale="$xscale" -v zscale="$zscale" -v scale="$scale" '{print $1/xscale, $2/xscale, $5/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$xgrd
awk -v xscale="$xscale" -v zscale="$zscale" -v scale="$scale" '{print $1/xscale, $2/xscale, $6/scale}' $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$vectorLowerLimit -Lu$vectorUpperLimit -R$region -I$inc -G$zgrd
fi
#-----------------------------------------------------
if [ $type == 'S' ] || [ $type == 'V1' ]
then
gmt begin $fig
gmt makecpt -C$cpt -T$scalarLowerLimit/$scalarUpperLimit -Iz

gmt grdimage $grd -R$region -J$projection -BWeSn -Bx10f5+l"$xlabel ($xscale$xunit)" -By10f5+l"$zlabel ($zscale$zunit)"

if [ $type == 'V1' ]
then
gmt grdvector $xgrd $zgrd -Ix1 -Q0.1i+eAl+n0.25i+h0.1 -W1p,gray -S20i -N
fi

awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\positive_finger | gmt plot -Ss0.005i -Gred   -N
awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\negative_finger | gmt plot -Ss0.005i -Ggreen -N

gmt colorbar -Dx$domain -Bxa1f0.5 -By+l"$scale$unit"

gmt end
fi
#-----------------------------------------------------
if [ $type == 'V2' ]
then
gmt begin $fig
gmt makecpt -C$cpt -T$vectorLowerLimit/$vectorUpperLimit -Iz
gmt subplot begin 2x1 -M0.0i/0.035i -Fs$width\i/0 -Srl -Scb -R$region -J$projection -A+jTR+o8p

gmt subplot set 0,0 
gmt grdimage $xgrd -Bwesn -Bx10f5+l"$xlabel ($xscale$xunit)" -By10f5+l"$zlabel ($zscale$zunit)"

awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\positive_finger | gmt plot -Ss0.005i -Gred   -N
awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\negative_finger | gmt plot -Ss0.005i -Ggreen -N
gmt subplot set 1,0 
gmt grdimage $zgrd -BWeSn -Bx10f5+l"$xlabel ($xscale$xunit)" -By10f5+l"$zlabel ($zscale$zunit)"

awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\positive_finger | gmt plot -Ss0.005i -Gred   -N
awk  -v xscale="$xscale" -v zscale="$zscale" '{print $1/xscale, $2/zscale}' $backupFolder\negative_finger | gmt plot -Ss0.005i -Ggreen -N

gmt colorbar -Dx$domain -Bxa1f0.5 -By+l"$scale$unit"

gmt subplot end
gmt end
fi
#-----------------------------------------------------
rm -f $grd $xgrd $zgrd

rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
