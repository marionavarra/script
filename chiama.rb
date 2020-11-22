#!/usr/bin/ruby
dir = '/run/user/1000/gvfs/'
p "DIR: " + dir
device = `sudo su - mario -c "ls #{dir} | grep mtp"`.chop
ora=`date +%Y-%m-%d-%H_%M_%S`
p device
p " "
path_device = "/Archivio\\ condiviso\\ interno/DCIM/"
p "sudo su - mario -c touch #{dir}#{device}#{path_device}test"
chiama = `sudo su - mario -c "touch #{dir}#{device}#{path_device}alarm_#{ora}"`
