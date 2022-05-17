#!/bin/bash
project=nuig02 #ucd01 dias01 nuig02 ngear015c

srun -N 1 -t 1:00:00 -A $project -p DevQ --pty bash -i
