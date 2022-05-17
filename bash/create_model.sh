#!/bin/bash

./octave.sh generate_interfaces.m

./octave.sh generate_materials.m

./octave.sh generate_regions.m

./create_tomography.sh

./create_Par_file.sh
