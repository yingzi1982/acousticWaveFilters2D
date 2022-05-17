#!/bin/bash

./octave.sh generate_electrostatic_fields.m

cd ../gmt
./plot_electrostatic_fields.sh
