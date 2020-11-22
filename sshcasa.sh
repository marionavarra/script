#!/bin/bash
lastIPFile=/home/mario/Documenti/script/lastIP.txt
if [ -f $lastIPFile ]; then
  rm $lastIPFile
fi
#echo "ssh -R 2222:127.0.0.1:22 mario@$ip" 
attiva=`sudo netstat -anp | grep ssh | grep ESTABLISHED | wc -l`
if [ $attiva == 0 ]
then
  wget http://www.pdpiedimonte.it/lastIP.txt -O /home/mario/Documenti/script/lastIP.txt
  ip=`cat /home/mario/Documenti/script/lastIP.txt`
  ssh -o ServerAliveInterval=290 -o ServerAliveCountMax=1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -N -R 2222:localhost:22 mario@$ip &
fi
