#!/bin/bash

# TODO: Apply additional logic similar to the taito script!

#SCENE=$WRKDIR/scenes/veach-bidir-mlt/veach-bidir-mlt.xml
SCENE=$WRKDIR/scenes/kitchen2/batch_pt.xml
SPP=5000

# Get a list of hosts
nodes=`scontrol show hostnames|xargs`
echo "nodes = $nodes" 

# Determine current worker name
me=$(hostname -s)
echo "me = $me"
 
# Determine master process (first node, id 0)
master=$(echo $nodes | cut -f 1 -d ' ')
echo "master = $master"

# Determine server nodes
workers=${nodes[@]/$master}
echo "workers = $workers"

# SLURM_LOCALID contains task id for the local node
localid=$SLURM_LOCALID
echo "localid = $localid" 

# Join hostnames with semicolons
workerlist=${workers// /;}
echo "workerlist = $workerlist"

# Save output to logs folder
cd $WRKDIR/mitsuba/logs

if [[ "$me" == "$master" && "$localid" -eq 0 ]]
then
   # Master
   echo "Master!"
   sleep 5
   command="mitsuba $SCENE -b 16 -c '$workerlist' -p 11 -Dspp=$SPP"
   echo "Master comand: $command"
   
   eval $command

   # Kill servers to complete job
   for srv in $workers
   do
      kill_command="ssh $srv 'pkill -U $USER mtssrv' &"
      echo "Running command $kill_command"
      eval $kill_command
   done
   wait
   echo 'All servers closed'
else
   # Worker
   echo "Worker!"
   mtssrv -q
fi
