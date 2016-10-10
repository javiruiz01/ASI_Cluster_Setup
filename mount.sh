#! /bin/bash
# Script para el montaje de un directorio en una maquina destino

function main {
  echo "hello from `basename $0`" 
  # Let's try a ssh

  echo "This is the ip I need to connect: $1"
  if [[ -z data.tar ]]
  then 
    rm data.tar
  fi
  tar -cf data.tar mount_raid.conf configurar_cluster.sh
  scp data.tar practicas@$1:~/
}

main "$@"
