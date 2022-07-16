#!/bin/bash

filter_type=$1
filter_dimension=$2

cp ../backup/Par_file.part_$filter_type\_$filter_dimension ../backup/Par_file.part
oldString=`grep ^title ../backup/Par_file.part`
newString="title                           = $filter_type$filter_dimension"
sed -i "s/$oldString/$newString/g" ../backup/Par_file.part

./create_model.sh $filter_type $filter_dimension

piezoelectric_effect=converse
./create_piezoelectricity.sh $filter_type $filter_dimension $piezoelectric_effect

./octave.sh generate_sources.m $filter_dimension

./octave.sh generate_stations.m  $filter_type $filter_dimension

#./gmt.sh preprocess
