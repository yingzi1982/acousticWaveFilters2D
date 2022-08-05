#!/bin/bash

filter_type=$1
filter_dimension=$2

./octave.sh generate_stations.m  $filter_type $filter_dimension

cat ../backup/STATIONS_LA > ../DATA/STATIONS
cat ../backup/STATIONS_LA2 >> ../DATA/STATIONS
#cat ../backup/STATIONS_SA >> ../DATA/STATIONS

rm ../backup/STATIONS_*
