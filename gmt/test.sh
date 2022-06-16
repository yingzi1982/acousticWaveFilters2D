#!/usr/bin/env bash
source /pdc/software/21.11/eb/software/Anaconda3/2021.05/bin/activate
conda activate gmt6
gmt begin ../figures/symbols
gmt plot -R0/10/0/10 -JX2.2i/1.4i -Baf -Sc0.5c -W1p,black -Gred << EOF
2 3
5 6
8 2
EOF
gmt end 
