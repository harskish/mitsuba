#!/bin/bash

#SBATCH --time 00:02:00
#SBATCH --nodes=4
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=16
#SBATCH --mem=200
#SBATCH --partition parallel
#SBATCH -o mitsuba_slurm.out

# Clean-up routine
function clean_up {
	echo 'Got SIGTERM, killing worker processes...'
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM

# One instance started per task => master starts mitsuba, workers mtssrv
srun bash mitsuba_task_single.sh

