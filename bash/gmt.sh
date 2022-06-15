#!/bin/bash

cd ../gmt

./plot_fields.sh potential 1E-6 1E0 V 
./plot_fields.sh electric 1E-6 1E6 V/m
./plot_fields.sh bodyforce 1E-6 1E13 N/m@+2@+
