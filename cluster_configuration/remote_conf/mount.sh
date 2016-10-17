#! /bin/bash

counterLine=0
while read -r line
do
  counterLine=$((counterLine+1))
  [[ $counterLine -ge 3 ]] && break
  if [[ $counterLine -eq 1 ]]
  then
    name=$line
  else
    mountpoint=$line
  fi
done < "mount_raid.conf"

# Dejamos lo del fstab para luego
if [[ ! -d $mountpoint ]]
then
  mkdir $mountpoint
else
  if [[ "$(ls -A $mountpoint)" ]]
  then
    echo "Not empty"
    exit 2
  else
    echo "empty"
  fi
fi

mount -t  $name $mountpoint
