#! /bin/bash

function my_print {
  echo "MY PRINT"
}

function check_execute {
  if [[ ! -x "$1" ]]
  then
    chmod +x "$1"
  fi
}

function error_message {
  echo "$1" 1>&2
  exit 2
}

function check_ip {
  if [ $# -eq 0 ]
  then
    echo "I need the ip address to test"
  fi

 # Bloques de uno a 3 numeros, del 1 al 9, separados por puntos
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $ip
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]] 
    then
      echo "valid ip: $ip"
    fi
    IFS=$OIFS
  else
    error_message "not a valid ip address in line $counterLine"
  fi
}

function main {
  if [ $# -eq 0 ]
  then
    error_message "USAGE: `basename $0` fichero_configuracion"

  fi
  CONF=$1
  if [[ ! -f $CONF ]]
  then
    error_message "ERROR: looks like the file doesn't exist"
  fi
  counterLine=0
  validLines=0
  while read -r line
  do
    counterLine=$((counterLine+1))

    # Ignoramos lineas que empiecen con #
    [[ "$line" == "#"* || -z "$line" ]] && continue
    echo "We are going to be using this line: $line"
    validLines=$((validLines+1))

    # Ahora comprobamos si cumple el formato
    # Separamos la linea en argumentos
    set -- $line

    # Guardamos las variables
    ip=$1
    name=$2
    service=$3

    # Comprobamos numero de palabras
    if [[ $# -ne 3 ]]
    then
      error_message "Format not accepted in line $counterLine"
    fi

    # Realizamos comprobaciones sobre las palabras
    check_ip "$ip"
    if [[ "$service" != *".conf" ]]
    then
      error_message "Format not accepted in line $counterLine"
    else
      echo "Valid service: $service"
    fi
    check_execute "$name.sh"
    case $name in 
      mount)
        ./mount.sh "$ip"
        ;;
      raid)
        ./raid.sh
        ;;
      nfs_server)
        ./nfs_server.sh
        ;;
      nfs_client)
        ./nfs_client
        ;;
      \?)
        error_message "It seems this is not a valid configuration: $name"
        ;;
    esac
  done < "$CONF"
}

main "$@"
