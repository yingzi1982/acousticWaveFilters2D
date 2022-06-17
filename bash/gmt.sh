#!/bin/bash

cd ../gmt

inc=`grep step ../DATA/Par_file_PIEZO | cut -d = -f 2`

#name=$1
#type=$2 #s, v1, v2 
#cpt=$3
#scale=$4
#unit=$5
#
#xinc=$6
#xlabel=$7
#xscale=$8
#xunit=$9
#
#zinc=$10
#zlabel=$11
#zscale=$12
#zunit=$13

./plot_fields.sh potential S GMT_seis.cpt 1E0 V $inc X 1E-6 m $inc Z 1E-6 m 
#./plot_fields.sh electric  1E6 V/m
#./plot_fields.sh bodyforce 1E13 N/m@+2@+


