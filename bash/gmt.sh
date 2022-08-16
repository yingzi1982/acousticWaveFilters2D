#!/bin/bash

filter_dimension=2D

if [ $filter_dimension == '2D' ]
then
bodyforce_unit=N/m@+2@+
electric_displacement_unit=C/m

elif [ $filter_dimension == '3D' ]
then
bodyforce_unit=N/m@+3@+
electric_displacement_unit=C/m@+2@+
fi

cd ../gmt

dx=`grep dx ../backup/meshInformation | cut -d = -f 2`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2`
dx2=`echo $dx | awk '{print $1*2}'`
dz2=`echo $dz | awk '{print $1*2}'`
dt=2.0e-10
#--------------------------------------------------
if true; then
./plot1DSignal.sh sourceTimeFunction 10 Time 1E-9 s "0 40" 2f1 Amp. 1E0 "" "-1 1" 1f0.5
fi
exit
#--------------------------------------------------
if false; then
./plot2DField.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $dx X 1E-6 m $dz Z 1E-6 m on
./plot2DField.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m on
./plot2DField.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m on
./plot2DField.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 $bodyforce_unit $dx X 1E-6 m $dz Z 1E-6 m on
./plot2DField.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 $bodyforce_unit $dx X 1E-6 m $dz Z 1E-6 m on
fi
#--------------------------------------------------
if false; then
for i in $(seq 1 35)
do
snapshot=snapshot_$i
snapshot_file=../backup/$snapshot
coordinate=`cat ../backup/SA_coordinate`
snapshot_x=`cat ../backup/SA_snapshots_x | awk -v i="$i" '{print $i}'`
snapshot_z=`cat ../backup/SA_snapshots_z | awk -v i="$i" '{print $i}'`
paste <(echo "$coordinate") <(echo "$snapshot_x")  <(echo "$snapshot_z") --delimiters ' ' | awk '{print $1,$2,0,0,$3,$4}' > $snapshot_file
./plot2DField.sh $snapshot V2  '-CGMT_seis.cpt -Iz'  1E-11 m $dx2 X 1E-6 m $dz2 Z 1E-6 m on
rm $snapshot_file
done

module load PDC ghostscript PrgEnv-gnu
cd ../figures
snapshot_file_list=`ls -v snapshot_*_V2.pdf`
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=snapshots.pdf $snapshot_file_list
rm -f snapshot_*_V2.pdf
module unload PDC ghostscript PrgEnv-gnu

fi
#--------------------------------------------------
if false; then
traceImage=LA_trace_image
traceImage_x=$traceImage\_x
traceImage_z=$traceImage\_z
traceImageFile=../backup/$traceImage
traceImage_xFile=../backup/$traceImage_x
traceImage_zFile=../backup/$traceImage_z
tmax=4.0e-8
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$3}' > $traceImage_xFile
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$4}' > $traceImage_zFile
./plot2DField.sh $traceImage_x S '-CGMT_gray.cpt -Iz' 1E-11 m $dx X 1E-6 m $dt Time 1E-9 s on
./plot2DField.sh $traceImage_z S '-CGMT_gray.cpt -Iz' 1E-11 m $dx X 1E-6 m $dt Time 1E-9 s on
rm $traceImage_xFile
rm $traceImage_zFile
fi
#--------------------------------------------------

if false; then
traceImage=LA_electric_displacement_image
traceImage_x=$traceImage\_x
traceImage_z=$traceImage\_z
traceImageFile=../backup/$traceImage
traceImage_xFile=../backup/$traceImage_x
traceImage_zFile=../backup/$traceImage_z
tmax=4.0e-8
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$3}' > $traceImage_xFile
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$4}' > $traceImage_zFile
./plot2DField.sh $traceImage_x S '-CGMT_gray.cpt -Iz' 5E-5 $electric_displacement_unit $dx X 1E-6 m $dt Time 1E-9 s on
./plot2DField.sh $traceImage_z S '-CGMT_gray.cpt -Iz' 5E-5 $electric_displacement_unit $dx X 1E-6 m $dt Time 1E-9 s on
rm $traceImage_xFile
rm $traceImage_zFile
fi
#--------------------------------------------------
if false; then
./plotSpectrogram.sh
fi
