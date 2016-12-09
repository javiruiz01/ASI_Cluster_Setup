#! /bin/bash

function check_ip {
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $IP
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      echo -e "[\e[32mINFO\e[0m] Valid IP"
    else
      exit 52
    fi
    IFS=$OIFS
  else
    exit 53
  fi
}

# Formato del fichero de configuracion
#   ruta-del-directorio-del-que-se-desea-hacer-backup
#   direccion-del-servidor-de-backup
#   ruta-de-directorio-destino-del-backup
#   periodicidad-del-backup-en-horas
lineCounter=0
while read -r line
do
  [[ $lineCounter -eq 0 ]] && directory=$line
  [[ $lineCounter -eq 1 ]] && server=$line
  check_ip "$server"
  [[ $lineCounter -eq 2 ]] && route=$line
  [[ $lineCounter -eq 3 ]] && delorean=$line
  [[ $lineCounter -gt 3 ]] && exit 51 
done < "backup_client.conf"


