#!/bin/bash

#SBATCH --time 00:15:00
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=1000
#SBATCH --partition batch
#SBATCH -o mitsuba_slurm.out

# Expose libs and bins
source $WRKDIR/mitsuba/setpath.sh
export LD_LIBRARY_PATH=$WRKDIR/libs/lib:$WRKDIR/libs/lib64:$LD_LIBRARY_PATH

# One instance started per task => master starts mitsuba, workers mtssrv
srun bash mitsuba_task_single.sh

