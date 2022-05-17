#!/bin/bash

module purge

echo -13.07019135 51.15862502 > ../backup/sr
echo -13.14 51.1456 > ../backup/rc

#./create_geological_data.sh

./octave.sh generate_sources.m

./create_model.sh

./octave.sh generate_stations.m
