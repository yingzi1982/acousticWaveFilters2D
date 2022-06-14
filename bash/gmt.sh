#!/bin/bash

cd ../gmt

#./plot_field.sh potential 0.000001 1 v
./plot_fields.sh potential 1E-6 1E0 v
./plot_fields.sh electric 1E-6 1E6 v/m

