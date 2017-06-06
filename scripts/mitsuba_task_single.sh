#!/bin/bash


#SCENE=$HOME/scenes/veach-bidir-mlt/veach-bidir-mlt.xml
#SCENE=$HOME/scenes/veach-bidir-pt/veach-bidir-pt.xml
SCENE=$HOME/scenes/kitchen2/batch_pt.xml

SPP=32


# Get a list of hosts
nodes=`scontrol show hostnames|xargs`
 
# Determine current worker name, short format
me=$(hostname -s)
 
# Determine master process (first node, id 0)
master=$(echo $nodes | cut -f 1 -d ' ')

# Determine server nodes
workers=${nodes[@]/$master}

# SLURM_LOCALID contains task id for the local node
localid=$SLURM_LOCALID
 
# Join hostnames with semicolons
workerlist=${workers// /;}

# Save output to logs folder
cd ~/mitsuba/logs

if [[ "$me" == "$master" && "$localid" -eq 0 ]]
then
   # Master
   sleep 5
   command="mitsuba $SCENE -c '$workerlist' -Dspp=$SPP"
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
   mtssrv -q
fi
