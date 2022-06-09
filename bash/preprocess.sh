#!/bin/bash
filter_type=SAW
filter_dimension=2D
piezoelectric_effect=converse

#./octave.sh generate_electrodeConductSurface.m $filter_type $filter_dimension
#
#./octave.sh generate_electricFields.m $filter_dimension

./octave.sh generate_piezoelectricity.m $piezoelectric_effect $filter_dimension

