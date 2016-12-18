#! /bin/bash

lineCounter=0
while read -r line
do
  [[ $counterLine -gt 1 ]] && exit 50
  directory=$line
  [[ ! -d $directory ]] && exit 49
  counterLine=$((counterLine+1))
done < "backup_server.conf"

[[ $counterLine -eq 0 ]] && exit 58

which rsync > /dev/null
if [[ $? -ne 0 ]] 
then
  echo -e "[\e[32mINFO\e[0m] Installing command 'rsync'"
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m rsync > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 54
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
else
  echo -e "[\e[32mINFO\e[0m] Command 'rsync' exists, continuing"
fi

exit 0
