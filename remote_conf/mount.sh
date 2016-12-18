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
  [[ "$(ls -A $mountpoint)" ]] && exit 12
  echo -e "[\e[32mINFO\e[0m] Directory is empty, continuing" 1>&2
fi

blkid | grep $name
[[ $? -ne 0 ]] &&  exit 13
echo -e "[\e[32mINFO\e[0m] Device exists, continuing" 1>&2

type=$(blkid -o value -s TYPE $name)
#echo "SOY EL TIPO: $type"
mount -t $type $name $mountpoint

# Ahora nos aseguramos que se monte siempre el dispositivo
[[ -n "`grep $name /etc/fstab`" ]] && exit 0
echo -e "[\e[32mINFO\e[0m] Adding device to '/etc/fstab' file" 1>&2
echo "$name $mountpoint $type default 0 0" >> /etc/fstab

exit 0
