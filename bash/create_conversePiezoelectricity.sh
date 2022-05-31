#!/bin/bash

./octave.sh generate_conversePiezoelectricity.m

cd ../gmt
./plot_electrostatic_fields.sh
