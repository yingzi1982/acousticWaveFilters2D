#!/bin/bash

./octave.sh generate_electrodeConductSurface.m SAW 2D

./octave.sh generate_electricFields.m 2D
exit

./octave.sh generate_piezoelectricity.m converse

