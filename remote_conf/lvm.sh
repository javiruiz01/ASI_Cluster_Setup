#! /bin/bash

# TODO: Hacer todas las comprobaciones despues de haber mirado la teoria
#       se hablan de cosas muy raras. Solo estan asignados los nombres
#       de las variables

function getTotalSize {
  if [[ -n "`echo ${array[1]} | grep G`" ]]
  then
    sizeNumber=$(echo ${array[1]} | tr -dc '0-9')
    sizeNumber=$((sizeNumber * ${sizes[G]}))
    totalSize=$((totalSize+sizeNumber))
    sizeNumber=0
  elif [[ -n "`echo $array[1] | grep M`" ]]
  then
    sizeNumber=$(echo $array[1] | tr -dc '0-9')
    sizeNumber=$((sizeNumber * ${sizes[M]}))
    totalSize=$((totalSize+sizeNumber))
    sizeNumber=0
  elif [[ -n "`echo $array[1] | grep K`" ]]
  then
    sizeNumber=$(echo $array[1] | tr -dc '0-9')
    sizeNumber=$((sizeNumber * ${sizes[K]}))
    totalSize=$((totalSize+sizeNumber))
    sizeNumber=0
  else
    exit 21
  fi
}

counterLine=0
counterPhysDevices=0
totalSize=0
#counterLogicDevices=0
#declare -a sizes
#declare -a logicDevices
declare -A sizes=([G]=1073741824 [M]=1048576 [K]=1024)
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
      echo -e "[\e[32mINFO\e[0m] Device is a block device, continuing"
    done
    # list=$line
    IFS=$OIFS
  fi
  if [[ $counterLine -gt 2 ]]
  then
    read -r -a array <<< "$line"
    #logicDevices[$counterLogicDevices]=${array[0]}
    #sizes[$counterLogicDevices]=${array[1]}
    #counterLogicDevices=$((counterLogicDevices+1))
    #group_size
    pruebita+=( ["${array[0]}"]="${array[1]}" )
    getTotalSize
    totalSize=$((sizeNumber + totalSize))
  fi
done < "lvm.conf"

echo "This is the total size we will be using: $totalSize"
# Comprobamos que el tamano total no es superior al de nuestro espacio fisico
diskTotal=$(df $PWD | awk '/[0-9]%/{print $(NF-2)}')
[[ $diskTotal -lt $totalSize ]] && exit 22 
echo -e "[\e[32mINFO\e[0m] The total size seems to be something we can handle, continuing"
# Pruebita con arrays asociativos
for key in ${!pruebita[@]}
do
  # echo "holita"
  echo ${key} ${pruebita[${key}]}
done

# Ahora vamos a instalar lvm
which lvm > /dev/null
if [[ $? -eq 0 ]]
then
  echo -e "[\e[32mINFO\e[0m] Command 'lvm' exists, continuing"
else
  echo -e "[\e[32mINFO\e[0m] Installing command 'lvm'"
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m lvm2 > /dev/null
  [[ $? -ne 0 ]] && exit 20
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
fi

exit 0
