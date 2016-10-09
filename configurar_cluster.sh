#! /bin/bash

function check_ip {
  if [ $# -eq 0 ]
  then
    echo "I need the IP address to test"
  fi
  # Bloques de uno a 3 numeros, del 1 al 9, separados por puntos
  if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    echo "valid IP, you can continue"
  else
    echo "not a valid IP address in line $counterLine"
    exit 2
  fi
}

function main {
  if [ $# -eq 0 ]
  then
    echo "USAGE: `basename $0` fichero_configuracion"
    exit 2
  fi
  CONF=$1
  if [[ ! -f $CONF ]]
  then
    echo "ERROR: looks like the file doesn't exist"
    exit 2
  fi
  counterLine=0
  while read -r line
  do
    counterLine=$((counterLine+1))
    # Ignoramos lineas que empiecen con #
    [[ "$line" == "#"* || -z "$line" ]] && continue
    echo "$line"
    # Ahora comprobamos si cumple el formato
    # Separamos la linea en argumentos
    set -- $line
    # Guardamos las variables
    IP=$1
    NAME=$2
    SERVICE=$3
    # Comprobamos numero de palabras
    if [[ $# -ne 3 ]]
    then
      echo "Format not accepted in line $counterLine"
    fi
    # Realizamos comprobaciones sobre las palabras
    check_ip "$IP"
    if [[ "$SERVICE" != *".conf" ]]
    then
      echo "Format not accepted in line $counterLine"
      exit 2
    fi
  done < "$CONF"
}

main "$@"
