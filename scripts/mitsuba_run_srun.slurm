#!/bin/bash

#SBATCH --time 00:02:00
#SBATCH --nodes=4
#SBATCH --ntasks=4
#SBATCH --mem=100
#SBATCH --partition parallel
#SBATCH -o mitsuba_srun.out

# Clean-up routine
function clean_up {
	echo 'Got SIGTERM, killing worker processes...'
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM

# Script that each worker executes

srun bash run_mts_test.sh

