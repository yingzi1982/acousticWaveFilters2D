#!/bin/bash

piezoelectric_effect=$1 

cd ../gmt

inc=`grep step ../DATA/Par_file_PIEZO | cut -d = -f 2`

if [ $piezoelectric_effect == 'converse' ]
then

./plot2D.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $inc X 1E-6 m $inc Z 1E-6 m
./plot2D.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $inc X 1E-6 m $inc Z 1E-6 m
./plot2D.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $inc X 1E-6 m $inc Z 1E-6 m
./plot2D.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 N/m@+2@+ $inc X 1E-6 m $inc Z 1E-6 m
./plot2D.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 N/m@+2@+ $inc X 1E-6 m $inc Z 1E-6 m

elif [ $piezoelectric_effect == 'direct' ]
then
echo ' '
fi

