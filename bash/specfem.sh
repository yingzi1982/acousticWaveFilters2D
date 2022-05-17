#!/bin/bash 

runningName=18A
workingDir=/ichec/work/ngear019b/yingzi/$runningName/
#rm -f $workingDir
mkdir -p /tmp/empty & rsync -r --delete /tmp/empty/ $workingDir
mkdir -p $workingDir
mkdir $workingDir/OUTPUT_FILES

cp -r ../DATA/ $workingDir
cp -r ../xmeshfem2D $workingDir
cp -r ../xspecfem2D $workingDir

cd $workingDir

module load intel/2018u4 gcc

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

if [ "$NPROC" -eq 1 ]; then
  ./xmeshfem2D
  ./xspecfem2D
else
  #mpiexec -n $NPROC ./xmeshfem2D
  #mpiexec -n $NPROC ./xspecfem2D
  mpirun -n $NPROC ./xmeshfem2D
  mpirun -n $NPROC ./xspecfem2D
fi
cd -
module unload intel/2018u4 gcc 
