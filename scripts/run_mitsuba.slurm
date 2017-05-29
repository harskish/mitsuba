#!/bin/bash

#SBATCH --time 00:02:00
#SBATCH --nodes=4
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=16
#SBATCH --mem=200
#SBATCH --partition parallel
#SBATCH -o mitsuba_slurm.out

# One instance started per task => master starts mitsuba, workers mtssrv
srun bash mitsuba_task_single.sh

