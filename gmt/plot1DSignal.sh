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
resample_rate=${2}
xlabel=${3}
xscale=${4}
xunit=${5}

backupFolder=../backup/
figFolder=../figures/
mkdir -p $figFolder
fig=$figFolder$name

originalxy=$backupFolder$name

xmin=`gmt info $originalxy -C | awk '{print $1}'`
xmax=`gmt info $originalxy -C | awk '{print $2}'`
ymin=`gmt info $originalxy -C | awk '{print $3}'`
ymax=`gmt info $originalxy -C | awk '{print $4}'`
normalization=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'|  awk '{printf "%d", $1}'`

timeDuration=`echo $xmin $xmax | awk -v xscale="$xscale" '{print ($2-$1)/xscale+1}'`

region=0/$timeDuration/-1/1

width=2.2
height=0.8
projection=X$width\i/$height\i

gmt begin $fig

awk -v xmin="$xmin" -v xscale="$xscale" -v resample_rate="$resample_rate" -v normalization="$normalization" 'NR%resample_rate==0 {print ($1-xmin)/xscale, $2/normalization}' $originalxy | gmt plot -J$projection -R$region -Bxa2f1+l"$xlabel ($xscale$xunit)" -Bya1f0.5 -Wthin,black #+l"Amp (x$normalization)"
gmt end

rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
