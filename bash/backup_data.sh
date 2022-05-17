#!/bin/bash
#module load gmt

workingDir=/ichec/work/ngear019b/yingzi/18A/
output_folder=$workingDir\OUTPUT_FILES/

backup_folder=../backup/

cp $output_folder/plot_source_time_function.txt $backup_folder

cp $output_folder/ARRAY.S* $backup_folder

./octave.sh generate_combined_signal.m

#original_time_seris=$output_folder/ARRAY.S1.PRE.semp
#processed_time_seris=$backup_folder/numerical_time_seris

#tmin=`gmt gmtinfo $original_time_seris -C | awk '{print $1}'`
#tmax=`gmt gmtinfo $original_time_seris -C | awk '{print $2}'`
#smin=`gmt gmtinfo $original_time_seris -C | awk '{print $3}'`
#smax=`gmt gmtinfo $original_time_seris -C | awk '{print $4}'`

#amplification=7.5337e+07
#normalization=`echo $smin $smax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'`

#cat $original_time_seris | awk -v tmin="$tmin"  -v normalization="$normalization" '{print $1-tmin, $2/normalization}'> $processed_time_seris
