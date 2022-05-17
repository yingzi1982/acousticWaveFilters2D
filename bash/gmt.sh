#!/bin/bash

module purge

cd ../gmt

#./plot_deployment.sh
./plot_sound_speed.sh

#./plot_single_signal.sh ARRAY.S1.PRE.semp
#./plot_single_signal.sh ARRAY.S1.BXX.semv
#./plot_single_signal.sh ARRAY.S1.BXZ.semv
#./plot_single_signal.sh hydrophone_signal
./plot_signal_compare.sh
