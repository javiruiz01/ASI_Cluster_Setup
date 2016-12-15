#! /bin/bash

# Empezamos leyendo las lineas del fichero de configuracion
counterLine=0
counterDevices=0
while read -r line
do
  counterLine=$((counterLine+1))
  [[ $counterLine -ge 4 ]] && exit 14 
  if [[ $counterLine -eq 1 ]]
  then
    name=$line
    echo -e "[\e[32mINFO\e[0m] This is name of the raid device: $name"
  elif [[ $counterLine -eq 2 ]]
  then
    level=$line
    # Comprobacion del nivel
    options="linear, raid0, 0, stripe, raid1, 1, mirror, raid4, 4, raid5, 5, raid6, 6, raid10, 10, multipath, mp, faulty, container"
    [[ $options != *"$level"* ]] && exit 19
    echo -e "[\e[32mINFO\e[0m] This is the level we will be using: $level"
  else
    devices=$line
    OIFS=$IFS
    devicesConf=""
    IFS=" "
    read -r -a device_list <<< "$line"
    for i in ${device_list[@]}
    do
      if [[ $counterDevices -eq 0 ]] 
      then
        devicesConf=$i
      else
        devicesConf=$devicesConf","$i
      fi
      echo -e "[\e[32mINFO\e[0m] This is one of the devices we will be using: $i"
      counterDevices=$((counterDevices+1))
      # Comprobaciones de los dispositivos
        # Existe el dispoistivo?
      #blkid | grep $i > /dev/null
      fdisk -l | grep $i > /dev/null
      [[ $? -eq 1 ]] && exit 16
        # El dispositivo es un dispositivo de bloques?
      [[ ! -b $i ]] && exit 17
      echo -e "[\e[32mINFO\e[0m] Device '$i' exists, continuing" 1>&2
    done
    IFS=$OIFS
  fi
done < "raid.conf"

# En realidad, lo de coger los dispositivos solo nos va a servir para comprobar
# que exite, porque al comando mdadm se lo pasamos directamente

# Comprobamos que mdadm está instalado
which mdadm > /dev/null 
if [[ $? -eq 0 ]]
then
  echo -e "[\e[32mINFO\e[0m] Command 'mdadm' exists, continuing"
else
  echo -e "[\e[32mINFO\e[0m] Installing command 'mdadm'"
  export DEBIAN_FRONTEND=noninteractive
  # -qq tiene implicito un -y
  apt-get -qq install mdadm --no-install-recommends > /dev/null 2> /dev/null   
  [[ $? -ne 0 ]] && exit 15
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
fi

# Ejecutamos el comando mdadm
echo -e '[\e[32mINFO\e[0m] echo y | mdadm '"--create $name --level=$level --raid-devices=$counterDevices $devices"
echo y | mdadm --create $name --level=$level --raid-devices=$counterDevices $devices
[[ $? -ne 0 ]] && exit 18
echo -e "[\e[32mINFO\e[0m] 'mdadm' command executed succesfully"

# Actualizams el fichero de configuracion de mdadm
[[ -n "`grep $devicesConf /etc/mdadm/mdadm.conf`" ]] && exit 0
echo "DEVICE $devices" >> /etc/mdadm/mdadm.conf
echo "ARRAY $name devices=$devicesConf" >> /etc/mdadm/mdadm.conf

echo -e "[\e[32mINFO\e[0m] succesfully added new devices to 'mdadm.conf' file"
exit 0
