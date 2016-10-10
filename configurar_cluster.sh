#! /bin/bash

function error_message {
  echo "$1" 1>&2
  exit 2
}

function check_ip {
  if [ $# -eq 0 ]
  then
    echo "I need the IP address to test"
  fi
 
 # Bloques de uno a 3 numeros, del 1 al 9, separados por puntos
  if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    echo "valid IP: $IP"
  else
    error_message "not a valid IP address in line $counterLine"
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
  
  while read -r line
  do
    counterLine=$((counterLine+1))
    
    # Ignoramos lineas que empiecen con #
    [[ "$line" == "#"* || -z "$line" ]] && continue
    echo "We are going to be using this line: $line"
    
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
      error_message "Format not accepted in line $counterLine"
    fi
    
    # Realizamos comprobaciones sobre las palabras
    check_ip "$IP"
    if [[ "$SERVICE" != *".conf" ]]
    then
      error_message "Format not accepted in line $counterLine"
    else 
      echo "Valid service: $SERVICE"
    fi
    
  done < "$CONF"
}

main "$@"
