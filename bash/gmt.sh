#!/bin/bash


cd ../gmt

dx=`grep dx ../backup/meshInformation | cut -d = -f 2`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2`
./plot2DField.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $dx X 1E-6 m $dz Z 1E-6 m off
./plot2DField.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m off
./plot2DField.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m off
./plot2DField.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m off
./plot2DField.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m off
exit

dx2=`echo $dx | awk '{print $1*2}'`
dz2=`echo $dz | awk '{print $1*2}'`

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
