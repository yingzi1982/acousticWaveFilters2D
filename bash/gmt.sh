#!/bin/bash

#process=$1 

cd ../gmt

#if [ $process == 'preprocess' ]
#then

dx=`grep dx ../backup/meshInformation | cut -d = -f 2`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2`
./plot2D.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $dx X 1E-6 m $dz Z 1E-6 m
./plot2D.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m
./plot2D.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m
./plot2D.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m
./plot2D.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m

#elif [ $process == 'postprocess' ]
#then
#echo ' '
#fi
