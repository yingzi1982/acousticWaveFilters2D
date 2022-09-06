#!/bin/bash

filter_type=$1
filter_dimension=$2

./octave.sh generate_electrodes.m $filter_type $filter_dimension

./octave.sh generate_interfaces.m $filter_type $filter_dimension

./octave.sh generate_materials.m $filter_dimension

./octave.sh generate_regions.m $filter_dimension 

./create_tomography.sh $filter_dimension

./create_Par_file.sh
