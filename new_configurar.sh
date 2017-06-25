#! /bin/bash

# Funcione que imprime las salidas con la informacion o los errores
function print {
  red="\e[31m"
  green="\e[32m"
  end="\e[0m"

  type=$1
  message=$2
  # Se nos pide que todos los mensajes de informacion salgan por la
  # salida de error en el enunciado
  if [[ $type == "info" ]]
  then
    echo -e "[${green}INFO${end}] $message"
  elif [[ $type == "usage" ]]
  then
    echo -e "[${green}USAGE${end}] $message"
  else
    echo -e "[${red}ERROR${end}] in line $counterLine:  $3" 1>&2
    exit $2
  fi
}

function setUp {
  if [[ -f data.tar ]]
  then
    rm data.tar
  fi
  tar -cf data.tar remote_conf/$2.sh $3 2>/dev/null
  print "info" "From here on out, everything should be working as expected. To be tested tomorrow, me voy a casa que estoy hasta la polla"
}

function check_ip {
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $ip
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      print "info" "Valid ip: $ip"
    fi
    IFS=$OIFS
  else
    print "error" "3" "Not a valid IP address"
  fi
}

function main {
  if [[ $# -ne 1 ]]
  then 
    print "usage" "$(basename $0) fichero_configuracion"
    exit 2
  fi
  
  CONF=$1
  if [[ ! -f $CONF ]]
  then
    counterLine=337
    print "error" "4" "Looks like the file '$CONF' doesn't exist"
  fi
  if [[ ! -s $CONF ]]
  then
    counterLine=347
    print "error" "5" "Looks like the file '$CONF' is empty"
  fi

  counterLine=0
  validLines=0
  while read -r line
  do
    counterLine=$((counterLine+1))
    [[ "$line" == "#"* || -z "$line" ]] && continue 
    print "info" "Beginning new line of 'fichero_configuracion': \n\t$line"
    validLines=$((validLines+1))

    set -- $line
    ip=$1
    name=$2
    service=$3

    if [[ $# -ne 3 ]]
    then
      print "error" "7" "Format of config file not accepted"
    fi
    check_ip "$ip"    
    # Hacer un STRING muy grande que tenga todos los servicios
    # que podemos ofrecer, y si no esta, error
    # Es ir demasiado lejos otra vez o esta bien
    # ? al final lo he hecho pero bueno
    options="[ mount, raid, lvm, nis_server, nis_client, nfs_server, nfs_client, backup_server, backup_client ]"
    if [[ $options != *"$name"* ]]
    then
      print "error" "8" "We don´t offer this service: '$name'. Check out our list of available services: \n\t$options"
    fi
    if [[ ! -f $service ]]
    then
      print "error" "65" "The configuration file does not exist, please type an existing one"
    fi
    if [[ ! -s $service ]]
    then
      print "error" "66" "The configuration file seems to be empty, please check it and try again"
    fi
    setUp "$ip" "$name" "$service"
  done < $CONF
}

main "$@"
