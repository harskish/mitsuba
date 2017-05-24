#!/bin/bash

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
 
# Join hostnames with semicolons
workerlist=${workers// /;}

if [[ "$me" == "$master" && "$localid" -eq 0 ]]
then
   # Run these if the process is the master task
   echo "I'm the master with number "$localid" in node "${me}". My subordinates are "$workers
   sleep 5
   command="mitsuba $HOME/scenes/veach-bidir-mlt/veach-bidir-mlt.xml -c '$workerlist'"
   echo "Master comand: $command"
   eval $command
else
   # Run these if the process is a worker
   # echo "I'm a worker number "$localid" in node "${me}
   mtssrv
fi
