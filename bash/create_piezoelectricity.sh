#!/bin/bash

./octave.sh generate_electricField.m

cd ../gmt
./plot_electrostatic_fields.sh
exit

./octave.sh generate_piezoelectricity.m converse
