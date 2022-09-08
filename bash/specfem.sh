#!/bin/bash 

filter_dimension=$1

runningName=`grep ^title ../DATA/Par_file | cut -d = -f 2 | sed -r "s/( )+//g"`

workingDir=/cfs/klemming/projects/snic/snic2022-22-620/yingzi/$runningName/
#rm -f $workingDir
mkdir -p /tmp/empty & rsync -r --delete /tmp/empty/ $workingDir
mkdir -p $workingDir
mkdir $workingDir/OUTPUT_FILES


case $filter_dimension in
#----------------------------------
2D)
cp -r ../DATA/ $workingDir
cp -r ../bin/xmeshfem2D $workingDir
cp -r ../bin/xspecfem2D $workingDir

cd $workingDir

#module load PrgEnv-cray

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

if [ "$NPROC" -eq 1 ]; then
  ./xmeshfem2D > meshfem.log
  ./xspecfem2D > specfem.log
else
  #mpiexec -n $NPROC ./xmeshfem2D
  #mpiexec -n $NPROC ./xspecfem2D
  #mpirun -n $NPROC ./xmeshfem2D
  #mpirun -n $NPROC ./xspecfem2D
  srun -n $NPROC ./xmeshfem2D > meshfem.log
  srun -n $NPROC ./xspecfem2D > specfem.log
fi
cd -
;;
#----------------------------------

#----------------------------------
3D)
echo "3D"
;;
#----------------------------------
*)
    echo -n "Wrong filter dimentsion!"
    ;;
esac
#module unload PrgEnv-cray
