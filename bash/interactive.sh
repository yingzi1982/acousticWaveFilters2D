#!/bin/bash
project=pdc-test-2022
#project=2021-46
partition=main #main long shared memory
srun -N 1 -t 4:00:00 -A $project -p $partition --pty bash -i
#salloc -N 1 -t 1:00:00 -A $project -p $partition
