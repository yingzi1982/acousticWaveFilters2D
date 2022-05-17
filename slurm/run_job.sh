#!/bin/bash 

#SBATCH -A ngear019b #ucd01 dias01 nuig02 ngear015c ngear019b
##SBATCH -p DevQ # DevQ: 4 nodes x 1 hours; ProdQ: 40 nodes x 72 hours
#SBATCH -N 1
#SBATCH -t 20:00:00
#SBATCH -o output.txt
#SBATCH -e error.txt
#SBATCH --mail-user=yingzi.ying@me.com
#SBATCH --mail-type=ALL

#cd $SLURM_SUBMIT_DIR

cd ../bash
./preprocess.sh
#./postprocess.sh
