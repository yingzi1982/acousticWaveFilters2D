#!/bin/bash
#module load git
operation=$1
folder="../README.md ../bash/*sh ../figures/* ../gmt/*cpt ../gmt/*sh ../octave/*m ../fortran/original/*f90 ../fortran/modified/*f90 ../slurm/*sh ../backup/Par_file.part_SAW_2D"
#../backup/* 

#folder=$2

if [ $operation == 'push' ]
then
git add $folder
git commit -m "pushing to Github"
git push origin master
elif [ $operation == 'pull' ]
then
git commit -m "pulling from Github"
git pull origin master
fi

#module unload git
cd -
