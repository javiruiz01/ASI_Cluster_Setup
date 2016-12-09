#! /bin/bash

function check_ip {
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $ip
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      echo -e "[\e[32mINFO\e[0m] Valid IP"
    else
      exit 43
    fi
    IFS=$OIFS
  else
    exit 44
  fi
}

# Comprobacion del fichero de configuracion
# Cada linea es: ip ruta_directorio_remoto punto_de_montaje
lineCounter=0
itemCounter=0
declare -a ip
declare -a remote
declare -a mount
while read -r line
do
  read -r -a array <<< "$line"
  [[ ${#array[@]} -ne 3 ]] && exit 45
  ip+=(${array[0]})
  remote+=(${array[1]})
  mount+=(${array[2]})
  # Ahora verificamos todo
  check_ip "${array[0]}"  # El resto de elementos corresponden al servidor NFS
                          # pensar en como probarlos
  lineCounter=$((lineCounter+1))
done < "nfs_client.conf"

[[ $lineCounter -eq 0 ]] && exit 42

lineCounter=$((lineCounter-1))
for i in `seq 0 $lineCounter` 
do
  echo "[IP]: ${ip[$i]}, [REMOTE]: ${remote[$i]}, [MOUNT]: ${mount[$i]}"
done

# Install necessary packages
which nfs-common > /dev/null
if [[ $? -ne 0 ]]
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m nfs-common > /dev/null
  [[ $? -ne 0 ]] && exit 46
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
else
  echo -e "[\e[32mINFO\e[0m] Packages already installed, continuing"
fi

for i in `seq 0 $lineCounter`
do
  if [[ ! -d ${mount[$i]} ]] 
  then
    echo -e "[\e[32mINFO\e[0m] Creating mounting point directory"
    mkdir ${mount[$i]}
  fi
  # Now we mount the remote directory addressing our host server
  echo 'mount'" ${ip[$i]}:${remote[$i]} ${mount[$i]}"
  [[ $? -ne 0 ]] && exit 47
  # Check to see if the NFS shares have been properly mounted
  #[[ ! -n "`mount -t nfs | grep ${ip[$i]}`" ]] && exit 48
  # Make mount permanent by adding to /etc/fstab
  if [[ -n "`grep ${ip[$i]}:${remote[$i]} /etc/fstab`" ]]
  then
    echo -e "[\e[32mINFO\e[0m] I'm already in the /etc/fstab file"
  else
    echo "${ip[$i]}:${remote[$i]} ${mount[$i]} ext4 default 0 0" # >> /etc/fstab
  fi
done

exit 0
