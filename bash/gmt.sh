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
xtick=50f25
ztick=10f5
#heightRatio=0.28
heightRatio=0
#--------------------------------------------------
if false; then
./plot1DSignal.sh sourceTimeFunction 10 Time 1E-9 s "0 40" 2f1 Amp. 1E0 "" "-1 1" 1f0.5
fi
#--------------------------------------------------
if false; then
./plot2DField.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $heightRatio $dx X 1E-6 m $xtick $dz Z 1E-6 m $ztick
./plot2DField.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $heightRatio $dx X 1E-6 m $xtick $dz Z 1E-6 m $ztick
./plot2DField.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $heightRatio $dx X 1E-6 m $xtick $dz Z 1E-6 m $ztick
./plot2DField.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 $bodyforce_unit $heightRatio $dx X 1E-6 m $xtick $dz Z 1E-6 m $ztick
./plot2DField.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 $bodyforce_unit $heightRatio $dx X 1E-6 m $xtick $dz Z 1E-6 m $ztick
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
./plot2DField.sh $snapshot V2  '-CGMT_seis.cpt -Iz'  1E-11 m $heightRatio $dx2 X 1E-6 m $xtick $dz2 Z 1E-6 m $ztick
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
xtick2=10f5
heightRatio2=0

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
./plot2DField.sh $traceImage_x S '-CGMT_gray.cpt -Iz' 1E-11 m $heightRatio2 $dx X 1E-6 m $xtick2 $dt Time 1E-9 s $ztick
./plot2DField.sh $traceImage_z S '-CGMT_gray.cpt -Iz' 1E-11 m $heightRatio2 $dx X 1E-6 m $xtick2 $dt Time 1E-9 s $ztick
rm $traceImage_xFile
rm $traceImage_zFile
fi
#--------------------------------------------------

if false; then
traceImage=LA_electric_displacement_polarization_image
traceImage_x=$traceImage\_x
traceImage_z=$traceImage\_z
traceImageFile=../backup/$traceImage
traceImage_xFile=../backup/$traceImage_x
traceImage_zFile=../backup/$traceImage_z
tmax=4.0e-8
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$3}' > $traceImage_xFile
cat $traceImageFile | awk -v tmax="$tmax" '$2 <=tmax {print $1,$2,$4}' > $traceImage_zFile
./plot2DField.sh $traceImage_x S '-CGMT_gray.cpt -Iz' 5E-5 $electric_displacement_unit $heightRatio2 $dx X 1E-6 m $xtick2 $dt Time 1E-9 s $ztick
./plot2DField.sh $traceImage_z S '-CGMT_gray.cpt -Iz' 5E-5 $electric_displacement_unit $heightRatio2 $dx X 1E-6 m $xtick2 $dt Time 1E-9 s $ztick
rm $traceImage_xFile
rm $traceImage_zFile
fi
#--------------------------------------------------
if false; then
./plotSpectrogram.sh
fi
#--------------------------------------------------
if true; then
#./plot1DSignal.sh sourceFrequencySpetrum 1 Freq 1E9 Hz "0 5" 5f2.5 Amp 1E-2 "V/Hz" "0 3" 1f0.5
#./plot1DSignal.sh  charge 10 Time 1E-9 s "0 20" 10f5 Charge 2E-10 "C" "-1 1" 1f0.5
#./plot1DSignal.sh current 10 Time 1E-9 s "0 20" 10f5 Current  1E "A" "-1 1" 0.5f0.25
#./plot1DSignal.sh sourceTimeFunction 10 Time 1E-8 s "0 10" 4f2 A  1 "A" "-1 1" 1f0.5
./plot1DSignal.sh charge 10 Time 1E-8 s "0 10" 2f1 Charge  2E-11 "C" "-1 1" 1f0.5
exit

admittance_file=../backup/admittance
admittance_real_file=../backup/admittance_real
admittance_imag_file=../backup/admittance_imag
cat $admittance_file | awk  '{print $1,$2}' > $admittance_real_file
cat $admittance_file | awk  '{print $1,$3}' > $admittance_imag_file
./plot1DSignal.sh admittance_real 1 Freq 1E9 Hz "0.5 1.5" 1f0.5 Amp 1E0 "" "-.2 .2" ''
./plot1DSignal.sh admittance_imag 1 Freq 1E9 Hz "0.5 1.5" 1f0.5 Amp 1E0 "" "-.3 .3" ''
rm -f $admittance_real_file $admittance_imag_file
exit
#./plot1DSignal.sh admittance_spectrum 1 Freq 1E9 Hz "0 3" 1f0.5 Amp 1E0 "" "-50 0" 25f12.5
#./plot1DSignal.sh admittance_spectrum 1 Freq 1E9 Hz "0.1 2.9" 1f0.5 Amp 1E0 "" "-30 0" 10f5

#./plot1DSignal.sh admittance 1 Freq 1E9 Hz "0.7 1.0" .1f0.05 Amp 1E1 "" "-.8 .8" .4f.2
#./plot1DSignal.sh current 10 Time 1E-8 s "0 10" 4f2 A  .1 "A" "-1 1" 1f0.5
#./plot1DSignal.sh voltage 10 Time 1E-8 s "0 10" 4f2 A  .1 "A" "-1 1" 1f0.5
fi
