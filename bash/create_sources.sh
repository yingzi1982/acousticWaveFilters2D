#!/bin/bash
filter_dimension=$1

./octave.sh generate_sources.m $filter_dimension

Par_file=../DATA/Par_file
NSOURCES=`grep -c '^xs' ../DATA/SOURCE`

oldString=`grep "^NSOURCES" $Par_file`
newString="NSOURCES                        = $NSOURCES"
sed -i "s/$oldString/$newString/g" $Par_file