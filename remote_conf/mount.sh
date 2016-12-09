#! /bin/bash

counterLine=0
while read -r line
do
  counterLine=$((counterLine+1))
  if [[ $counterLine -ge 3 ]] 
  then 
    exit 11
  fi

  if [[ $counterLine -eq 1 ]]
  then
    name=$line
    echo -e "[\e[32mINFO\e[0m] This is name of the device: $name" 1>&2
  else
    mountpoint=$line
    echo -e "[\e[32mINFO\e[0m] This is the mounting point: $mountpoint" 1>&2
  fi
done < "mount_raid.conf"

if [[ ! -d $mountpoint ]]
then 
  echo -e "[\e[32mINFO\e[0m] Creating directory" 1>&2
  mkdir $mountpoint
else
  if [[ "$(ls -A $mountpoint)" ]]
  then
    exit 12
  else
    echo -e "[\e[32mINFO\e[0m] Directory is empty, continuing" 1>&2
  fi
fi

blkid | grep $name
if [[ $? -eq 1 ]]
then
  exit 13
else
  echo -e "[\e[32mINFO\e[0m] Device exists, continuing" 1>&2
fi

# mount -t ext4 $name $mountpoint

# Ahora nos aseguramos que se monte siempre el dispositivo
if [[ -n "`grep $name /etc/fstab`" ]]
then 
  echo -e "[\e[32mINFO\e[0m] I'm already in the /etc/fstab file"
else
  echo "$name $mountpoint ext4 default 0 0" >> /etc/fstab
fi

exit 0
