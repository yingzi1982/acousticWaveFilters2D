#!/bin/bash
module load PrgEnv-cray

# configure
echo ">>configuring"
currentdir=`pwd`
cd $currentdir
cd ../../../
#./configure CC=icc FC=ifort MPIFC=mpiifort --with-mpi > configure.log
#./configure FC=gfortran CC=gcc MPIFC=mpif90 --with-mpi > configure.log
./configure FC=ftn MPIFC=ftn CC=cc --with-mpi > configure.log

# make
make clean > making.log
echo "made clean" 
make xmeshfem2D >> making.log
echo "made xmeshfem2D"
make xspecfem2D >> making.log
echo "made xspecfem2D"

# link
echo ">>coping executables"
cd $currentdir
cp -f ../../../bin/xmeshfem2D ../
echo "linked xmeshfem2D"
cp -f ../../../bin/xspecfem2D ../
echo "linked xspecfem2D"

module unload PrgEnv-cray
