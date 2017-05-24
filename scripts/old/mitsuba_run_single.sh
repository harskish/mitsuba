#!/bin/bash

# Run mitsuba on a single 20-20 core node

#SBATCH -p test
#SBATCH --time=00:01:00
#SBATCH --mem=2000
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH -o mitsuba_single.out

# No srun (that forces a single core)
mitsuba ~/scenes/veach-bidir-mlt/veach-bidir-mlt.xml

echo 'Done!'
