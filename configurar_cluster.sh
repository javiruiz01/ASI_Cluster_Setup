#! /bin/bash

# Funcione que imprime cosas 
function print {
  red="\e[31m"
  green="\e[32m"
  end="\e[0m"
  
  type=$1
  message=$2

  if [[ $type == "info" ]]
  then
    echo -e "[${green}INFO${end}] $message" 1>&2
  elif [[ $type == "usage" ]]
  then 
    echo -e "[${green}USAGE${end}] $message" 1>&2
  else 
    echo -e "[${red}ERROR${end}] in line $counterLine:  $3" 1>&2
    exit $2
  fi
}

function setUp {
  print "info" "I'm in the mount function"
  if [[ -z data.tar ]]
  then
    rm data.tar
  fi
  cd remote_conf
  print "info" "Let's compress this"
  tar -cf data.tar $2.sh $3
  echo `pwd`
  scp data.tar root@$1:~/
  print "info" "Connecting via SSH"
  ssh root@$1 'tar -xvf data.tar && rm data.tar; ./'"$2"'.sh'
  # Ahora cogemos los codigos de errores
  code=$?
  case $code in
    11)
      counterLine=9
      print "error" "11" "From the remote machine, the conf file '$3' seems to have some errors"
      ;;
    12)
      counterLine=29
      print "error" "12" "From the remote machine, mounting point does not seem to be empty"
      ;; 
    13)
      counterLine=37
      print "error" "13" "From remote machine, device does not seems to exist"
      ;;
  esac
}

function check_execute {
  if [[ ! -x "$1" ]]
  then
    chmod +x "$1"
  fi
}

function check_ip {
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
    print "error" "3" "Not a valid ip address"
  fi
}

function main {
  if [[ $# -eq 0 ]]
  then
    print "usage" "`basename $0` fichero_configuracion"
    exit 2
  fi
  CONF=$1
  if [[ ! -f $CONF ]]
  then
    print "error" "4" "Looks like the file '$CONF' doesn't exist"
  fi
  if [[ ! -s $CONF ]]
  then
    counterLine=1
    print "error" "5" "Looks like the file '$CONF' is empty"
  fi
  if [[ ! -r $CONF ]]
  then
    print "error" "6" "Looks like I can't read the '$CONF' file"
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
      print "error" "7" "Format not accepted in line $counterLine"
    fi
    
    # Realizamos comprobacion sobre la ip
    check_ip "$ip"

    # Realizamos comprobacion sobre el servico    
    # name=$name.sh
    if [[ ! -r scripts_services/$name.sh ]]
    then
      print "error" "8" "Service $name does not seem to exist"
    fi
    if [[ "$service" != *".conf" ]]
    then
      print "error" "9" "Format not accepted in line $counterLine"
    else
      print "info" "Valid service: $service"
    fi
    check_execute "scripts_services/$name.sh"
    case $name in 
      mount)
        setUp "$ip" "$name" "$service"
        ;;
      raid)
        setUp "$ip" "$name" "$service"
        ;;
      nfs_server)
        setUp "$ip" "$name" "$service"
        ;;
      nfs_client)
        setUp "$ip" "$name" "$service"
        ;;
      \?)
        print "error" "10" "It seems this is not a valid configuration: $name"
        ;;
    esac
  done < "$CONF"
}

main "$@"
