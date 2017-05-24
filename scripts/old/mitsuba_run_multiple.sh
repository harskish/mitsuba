#!/bin/bash
#SBATCH -p parallel
#SBATCH --time=00:02:00
#SBATCH --nodes=3
#SBATCH --ntasks=3
#SBATCH --cpus-per-task=8
#SBATCH --mem=2000
#SBATCH -o mitsuba_multiple.out

#exclusive?

# Get a list of hosts using python-hostlist
nodes=`hostlist --expand $SLURM_NODELIST|xargs`
 
# Determine current worker name
me=$(hostname)
 
# Determine master process (first node, id 0)
master=$(echo $nodes | cut -f 1 -d ' ')

# Determine server nodes
workers=${nodes[@]/$master}

# SLURM_LOCALID contains task id for the local node
localid=$SLURM_LOCALID
 
if [[ "$me" == "$master" && "$localid" -eq 0 ]]
then
   # Run these if the process is the master task
   echo "I'm the master with number "$localid" in node "${me}". My subordinates are "$workers
   sleep 5
   command="mitsuba -p 7 $HOME/scenes/veach-bidir-mlt/veach-bidir-mlt.xml -c $workers"
   echo "Master comand: $command"
   eval $command
else
   # Run these if the process is a worker
   echo "I'm a worker number "$localid" in node "${me}
   mtssrv -p 8
fi
