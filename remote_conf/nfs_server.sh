#! /bin/bash

# Do stuff
lineCounter=0
declare -a directories
i=0
# Habran x lineas con x rutas a directorios exportados
while read -r line
do
  # Comprobar que rutas existen en la maquina 
  [[ ! -d $line ]] && exit 36
  # Probar si esta linea funciona :P
  [[ ! -x $line ]] || [[ ! -r $line ]] || [[ ! -w $line ]] && exit 37 
  # Si hemos pasado las pruebas, pues lo guardamos en el array
  directories[i]=$line
  i=$((i+1))
  lineCounter=$((lineCounter+1))
done < "nfs_server.conf"

[[ $lineCounter -eq 0 ]] && exit 39 # Ver bien el numero de exit

# Comprobamos que el array tiene lo que queremos
for i in ${directories[@]}
do
  echo "[DIRECTORY]: $i"
done

# We need to install nfs-kernel-server
`nfs-kernel-server status`  > /dev/null
if [[ $? -ne 0 ]] 
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m nfs-kernel-server > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 38
  echo -e "[\e[32mINFO\e[0m] Package 'nfs-kernel-server' installed correctly"
else
  echo -e "[\e[32mINFO\e[0m] Command 'nfs-kernel-server' exists, continuing"
fi

# Configure the NFS Exports on the Host Server
for i in ${directories[@]}
do
  # Comprobar que no exista ya una linea con ese directorio
  if [[ -n "`grep $i /etc/exports`" ]]
  then
    continue
  fi
  # Preguntar por la parte de todas las interfaces del servidor, ponemos IP de ejemplo
  echo "$i 111.111.111.111 (rw,sync,no_subtree_check)" >> /etc/exports
done

# Create the NFS table that holds the exports
echo 'exportfs -a'
[[ $? -ne 0 ]] && exit 40

# Start NFS service
echo 'service nfs-kernel-server start' 
[[ $? -ne 0 ]] && exit 41

exit 0
