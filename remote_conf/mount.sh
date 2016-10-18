#! /bin/bash

counterLine=0
while read -r line
do
  counterLine=$((counterLine+1))
  if [[ $counterLine -ge 3 ]] 
  then
    echo -e "[\e[31mERROR\e[0m] The conf file seems to have some errors"
  fi

  if [[ $counterLine -eq 1 ]]
  then
    echo -e "[\e[32mINFO\e[0m] This is name of the device: $name"
    name=$line
  else
    echo -e "[\e[32mINFO\e[0m] This is the mounting point: $mountpoint"
    mountpoint=$line
  fi
done < "mount_raid.conf"

if [[ ! -d $mountpoint ]]
then 
  echo -e "[\e[32mINFO\e[0m] Creating directory"
  mkdir $mountpoint
else
  if [[ "$(ls -A $mountpoint)" ]]
  then
    echo -e "[\e[31mERROR\e[0m] Directory does not seems to be empty"
    exit 2
  else
    echo -e "[\e[32mINFO\e[0m] Directory is empty, continuing"
  fi
fi

mount -t ext4 $name $mountpoint

# Ahora nos aseguramos que se monte siempre el dispositivo
if [[ -n "`grep $name /etc/fstab`" ]]
then 
  echo -e "[\e[32mINFO\e[0m] I'm already in the /etc/fstab file"
else
  echo "$name $mountpoint ext4 default 0 0" >> /etc/fstab
fi
