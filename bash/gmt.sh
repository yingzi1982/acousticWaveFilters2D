#!/bin/bash


cd ../gmt

dx=`grep dx ../backup/meshInformation | cut -d = -f 2`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2`
#./plot2D.sh potential S   '-CGMT_seis.cpt -Iz'  1E0  V        $dx X 1E-6 m $dz Z 1E-6 m
#./plot2D.sh electric  V1  '-CGMT_hot.cpt -Iz'   1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m
#./plot2D.sh electric  V2  '-CGMT_seis.cpt -Iz'  1E6  V/m      $dx X 1E-6 m $dz Z 1E-6 m
#./plot2D.sh bodyforce V1  '-CGMT_hot.cpt -Iz'   1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m
#./plot2D.sh bodyforce V2  '-CGMT_seis.cpt -Iz'  1E13 N/m@+2@+ $dx X 1E-6 m $dz Z 1E-6 m

dx2=`echo $dx | awk '{print $1*2}'`
dz2=`echo $dz | awk '{print $1*2}'`

for i in $(seq 1 50)
do
snapshot=snapshot_$i
snapshot_file=../backup/$snapshot
coordinate=`cat ../backup/SA_coordinate`
snapshot_x=`cat ../backup/SA_snapshots_x | awk -v i="$i" '{print $i}'`
snapshot_z=`cat ../backup/SA_snapshots_z | awk -v i="$i" '{print $i}'`
paste <(echo "$coordinate") <(echo "$snapshot_x")  <(echo "$snapshot_z") --delimiters ' ' | awk '{print $1,$2,0,0,$3,$4}' > $snapshot_file
./plot2D.sh $snapshot V2  '-CGMT_seis.cpt -Iz'  1E-11 m $dx2 X 1E-6 m $dz2 Z 1E-6 m
rm $snapshot_file
done
exit

module load PDC ghostscript
cd ../figures
snapshot_file_list=`ls -v snapshots_*pdf`
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=snapshots.pdf $snapshot_file_list
rm -f snapshots_*.pdf
module unload PDC ghostscript
