#! /bin/bash

# This function will replace error_message
function print {
  red="\e[31m"
  green="\e[32m"
  end="\e[0m"
  
  type=$1
  message=$2

  if [[ $type == "info" ]]
  then
    echo -e "${green}INFO:${end} $message" 1>&2
  elif [[ $type == "usage" ]]
  then 
    echo -e "${green}USAGE:${end} $message"
  else 
    echo -e "${red}ERROR${end} in line $counterLine:  $message" 1>&2
    exit 2
  fi
}

function check_execute {
  if [[ ! -x "$1" ]]
  then
    chmod +x "$1"
  fi
}

function check_ip {
  if [ $# -eq 0 ]
  then
    print "error" "I need the ip address to test"
  fi

 # Bloques de uno a 3 numeros, del 1 al 9, separados por puntos
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
    print "error" "Not a valid ip address in line $counterLine"
  fi
}

function main {
  if [ $# -eq 0 ]
  then
    print "usage" "`basename $0` fichero_configuracion"
    exit 2
  fi
  CONF=$1
  if [[ ! -f $CONF ]]
  then
    print "error" "Looks like the file '$CONF' doesn't exist"
  fi
  if [[ ! -s $CONF ]]
  then
    print "error" "Looks like the file '$CONF' is empty"
  fi
  if [[ ! -r $CONF ]]
  then
    print "error" "Looks like I can't read the '$CONF' file"
  fi
  counterLine=0
  validLines=0
  while read -r line
  do
    counterLine=$((counterLine+1))

    # Ignoramos lineas que empiecen con #
    [[ "$line" == "#"* || -z "$line" ]] && continue
    print "info" "We are going to be using this line: $line"
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
      print "error" "Format not accepted in line $counterLine"
    fi
    
    # Realizamos comprobacion sobre la ip
    check_ip "$ip"

    # Realizamos comprobacion sobre el servico    
    # name=$name.sh
    if [[ ! -r scripts_services/$name.sh ]]
    then
      print "error" "Service $name does not seem to exist"
    fi
    if [[ "$service" != *".conf" ]]
    then
      print "error" "Format not accepted in line $counterLine"
    else
      print "info" "Valid service: $service"
    fi
    check_execute "scripts_services/$name.sh"
    case $name in 
      mount)
        scripts_services/mount.sh "$ip"
        ;;
      raid)
        scripts_services/raid.sh
        ;;
      nfs_server)
        scripts_services/nfs_server.sh
        ;;
      nfs_client)
        scripts_services/nfs_client.sh
        ;;
      \?)
        print "error" "It seems this is not a valid configuration: $name"
        ;;
    esac
  done < "$CONF"
}

main "$@"
