#! /bin/bash

lineCounter=0
while read -r line
do
  [[ $counterLine -gt 1 ]] && exit 50
  directory=$line
  [[ ! -d $directory ]] && exit 49
  counterLine=$((counterLine+1))
done < "backup_server.conf"


