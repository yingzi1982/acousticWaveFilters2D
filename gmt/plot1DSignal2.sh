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
xrange=${6}
xtick=${7}

ylabel=${8}
yscale=${9}
yunit=${10}
yrange=${11}
ytick=${12}

backupFolder=../backup/
figFolder=../figures/
mkdir -p $figFolder
fig=$figFolder$name

originalxy=$backupFolder$name

xmin=`echo $xrange | awk '{print $1}'`
xmax=`echo $xrange | awk '{print $2}'`
ymin=`echo $yrange | awk '{print $1}'`
ymax=`echo $yrange | awk '{print $2}'`

region=$xmin/$xmax/$ymin/$ymax

width=2.2
height=1.8
projection=X$width\i/$height\i

gmt begin $fig

awk -v xscale="$xscale" -v yscale="$yscale" -v resample_rate="$resample_rate" 'NR%resample_rate==0 {print $1/xscale, $2/yscale}' $originalxy | gmt plot -J$projection -R$region -Bx$xtick+l"$xlabel ($xscale$xunit)" -By$ytick+l"$ylabel " -Wthin,red,.
awk -v xscale="$xscale" -v yscale="$yscale" -v resample_rate="$resample_rate" 'NR%resample_rate==0 {print $1/xscale, $3/yscale}' $originalxy | gmt plot -J$projection -R$region -Bx$xtick+l"$xlabel ($xscale$xunit)" -By$ytick+l"$ylabel " -Wthin,blue,-
awk -v xscale="$xscale" -v yscale="$yscale" -v resample_rate="$resample_rate" 'NR%resample_rate==0 {print $1/xscale, $4/yscale}' $originalxy | gmt plot -J$projection -R$region -Bx$xtick+l"$xlabel ($xscale$xunit)" -By$ytick+l"$ylabel " -Wthin,black

gmt legend -DjRT+w5.5c+o0.25c -F+p1p+gbeige+s <<- EOF
S 0.5c - 0.9c - 4p,green 1.2c Parsons & Sclater (1977)
S 0.5c - 0.9c - 4p,white 1.2c Stein & Stein (1992)
S 0.5c s 0.4c blue - 1.2c Modal depth estimates
EOF
gmt end

rm -f gmt.conf
rm -f gmt.history
#module unload gmt
conda deactivate
