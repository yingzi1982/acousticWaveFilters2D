#!/bin/bash 

pkg_name=xxx

conda create --name $pkg_name
conda activate $pkg_name

conda config --prepend channels conda-forge
conda install python=3.9 $pkg_name

#source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
#conda activate $pkg_name
