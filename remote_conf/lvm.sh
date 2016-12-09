#! /bin/bash

# TODO: Hacer todas las comprobaciones despues de haber mirado la teoria
#       se hablan de cosas muy raras. Solo estan asignados los nombres
#       de las variables

function getTotalSize {
  # Tener en cuenta que si ponemos la version anterior, peta en el bucle de
  # leida del fichero
  sizeNumber=$(echo ${array[1]} | tr -dc '0-9')
  [[ -n "`echo ${array[1]} | grep G`" ]] && sizeNumber=$((sizeNumber * ${sizes[G]}))
  [[ -n "`echo ${array[1]} | grep K`" ]] && sizeNumber=$((sizeNumber * ${sizes[K]}))
  totalSize=$((totalSize+sizeNumber))
}

counterLine=0
counterPhysDevices=0
totalSize=0
declare -A sizes=([G]=1024 [M]=1 [K]=0.0009765625)
declare -A pruebita
while read -r line
do
  counterLine=$((counterLine+1))
  [[ $counterLine -eq 1 ]] && name=$line
  # [[ $counterLine -eq 2 ]] && list=$line
  if [[ $counterLine -eq 2 ]]
  then
    devices=$line
    OIFS=$IFS
    IFS=" "
    read -r -a deviceList <<< "$line"
    for i in ${deviceList[@]}
    do
      # La lista de dispositivos se pasa tal cual al comando correspondiente
      # en lvm, lo que si que hay que comprobar es que los dispositivos existen
      blkid | grep $i > /dev/null
      #[[ $? -ne 0 ]] && exit 21
      echo -e "[\e[32mINFO\e[0m] Device $i is a block device, continuing"
    done
    # list=$line
    IFS=$OIFS
  fi
  if [[ $counterLine -gt 2 ]]
  then
    read -r -a array <<< "$line"
    getTotalSize
    pruebita+=(["${array[0]}"]="$sizeNumber")
    sizeNumber=0
  fi
done < "lvm.conf"

[[ $counterLine -lt 3 ]] && exit 23

echo "This is the total size we will be using: $totalSize"
# Comprobamos que el tamano total no es superior al de nuestro espacio fisico
diskTotal=$(df $PWD | awk '/[0-9]%/{print $(NF-2)}')
diskTotal=$((diskTotal))
[[ $diskTotal -lt $totalSize ]] && exit 22
echo -e "[\e[32mINFO\e[0m] The total size seems to be something we can handle, continuing"

# Pruebita con arrays asociativos
for key in ${!pruebita[@]}
do
  # echo "holita"
  echo "[KEY]: ${key} and [VALUE]: ${pruebita[${key}]}"
done

# Ahora vamos a instalar lvm
which lvm > /dev/null
if [[ $? -eq 0 ]]
then
  echo -e "[\e[32mINFO\e[0m] Command 'lvm' exists, continuing"
else
  echo -e "[\e[32mINFO\e[0m] Installing command 'lvm'"
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m lvm2 > /dev/null  2> /dev/null
  [[ $? -ne 0 ]] && exit 20
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
fi

# First, we create the virtual group

# We mark the physical volumes within LVM to indicate that they are ready
# to be added to a volume group
echo 'pvcreate'"${deviceList[@]}"
[[ $? -ne 0 ]] && exit 27

# We create the volume group and add the physical volumes to it
echo 'vgcreate '"$name ${deviceList[@]}"
[[ $? -ne 0 ]] && exit 24

# Now we create logical volumes
volCounter=0
for key in ${!pruebita[@]}
do
  echo 'lvcreate'" -L${pruebita[${key}]} -n ${key} $name"
  [[ $? -ne 0 ]] && exit 25
  volCounter=$((volCounter+1))
  # Y ahora le damos formato a lo que acabamos de crear
  echo 'mkfs.ext4'" /dev/$name/${key}"
  [[ $? -ne 0 ]] && exit 26
  # TODO: Agregar al /etc/fstab, pero en un directorio que no sabemos 
  mkdir -p /mnt/$name
  if [[ -n "`grep /dev/$name/${key} /etc/fstab`" ]]
  then
    echo -e "[\e[32mINFO\e[0m] I'm already in the /etc/fstab file"
  else
    echo "/dev/$name/${key} /mnt/$name ext4 default 0 0" # >> /etc/fstab 
  fi
done

exit 0













