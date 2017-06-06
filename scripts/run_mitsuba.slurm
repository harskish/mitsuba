#!/bin/bash

#SBATCH --time 00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=1000
#SBATCH --partition parallel
#SBATCH -o mitsuba_slurm.log

# Make mitsuba and libraries visible
module load gcc/4.7.2
module load intelmpi/4.1.0
module load boost/1.54
source ~/mitsuba/setpath.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/libs/glew/lib64:$HOME/libs/xerces/lib:$HOME/libs/ilmbase/lib:$HOME/libs/openexr/lib

# One instance started per task => master starts mitsuba, workers mtssrv
srun bash mitsuba_task_single.sh

