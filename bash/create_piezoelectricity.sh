#!/bin/bash

./octave.sh generate_electricFields2D.m

./octave.sh generate_piezoelectricity.m converse

cd ../gmt
./plot_electrostatic_fields.sh
./plot_bodyforce_field.sh

