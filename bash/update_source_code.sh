#!/bin/bash

code_type=$1

if [ $code_type == 'original' ]
then
echo 'copying the original code...'
cp -rf ../fortran/original/src/ ../../../
elif [ $code_type == 'modified' ]
then
echo 'copying the modified code...'
cp -rf ../fortran/modified/specfem2D/prepare_source_time_function.f90 \
       ../fortran/modified/specfem2D/compute_add_sources_viscoelastic.f90 \
       ../fortran/modified/specfem2D/read_save_binary_database.f90 \
       ../../../src/specfem2D/ 
fi
