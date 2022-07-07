#!/bin/bash

filter_type=SAW
filter_dimension=2D
piezoelectric_effect=converse

./create_piezoelectricity.sh $filter_type $filter_dimension $piezoelectric_effect
./gmt.sh $piezoelectric_effect
