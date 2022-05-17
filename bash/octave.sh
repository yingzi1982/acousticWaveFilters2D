#!/bin/bash
#module load octave/4.4.1
module load octave

octave_script=$1
input_parameters=$2
input_parameters2=$3

cd ../octave

./$octave_script $input_parameters $input_parameters2

module unload octave
