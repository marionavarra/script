#!/bin/bash
rm /home/mario/set_ora_accesso.php?tempo=*
orario=`date`
carica=`cat /proc/acpi/battery/BAT1/state | grep discharging | wc -l`
wget "http://www.pdpiedimonte.it/set_ora_accesso.php?carica="$carica"&tempo=$orario" -O accesso.txt
