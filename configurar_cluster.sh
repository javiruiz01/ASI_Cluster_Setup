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
  tar -cf data.tar remote_conf/$2.sh $3 > /dev/null
  scp data.tar root@$1:~/ > /dev/null
  print "info" "Connecting via SSH"
  ssh -n root@$1 'tar -xvf data.tar && rm data.tar; ./'"$2"'.sh' 2>/dev/null
  code=$?
  case $code in
    0)
      print "info" "Next step"
      cd /home/practicas/cluster_configuration/
      ;;
    11)
      counterLine=9
      print "error" "$code" "From the remote machine, the conf file $3 has too many lines"
      ;;
    12)
      counterLine=27
      print "error" "$code" "From the remote machine, mounting point does not seem to be empty"
      ;;
    13) 
      counterLine=32
      print "error" "$code" "From remote machine, device does not seems to exist"
      ;;
    14)
      counterLine=9
      print "error" "$code" "From remote machine, the conf file $3 seems to have too many lines"
      ;;
    15)
      counterLine=65
      print "error" "$code" "From remote machine, could not install 'mdadm' command"
      ;;
    16)
      counterLine=41
      print "error" "$code" "From remote machine, device doesn't seem to exist"
      ;;
    17)
      counterLine=43
      print "error" "$code" "From remote machine, device is not a block device"
      ;;
    18)
      counterLine=72
      print "error" "$code" "From remote machine, command 'mdadm' failed"
      ;;
    19)
      counterLine=19
      print "error" "$code" "From remote machine, invalid RAID level"
      ;;
    20)
      counterLine=67
      print "error" "$code" "From remote machine, installation of 'lvm2' command has failed"
      ;;
    21)
      counterLine=34
      print "error" "$code" "From remote machine, one of the devices doesn't exist"
      ;;
    22)
      counterLine=55
      print "error" "$code" "From remote machine, total size seems to be too big for the machine"
      ;;
    23)
      counterLine=49
      print "error" "$code" "From remote machine, not enough lines in lvm.conf"
      ;;
    24)
      counterLine=102
      print "error" "$code" "From remote machine, failed at 'vgcreate' command"
      ;;
    25)
      counterLine=105
      print "error" "$code" "From remote machine, failed at 'lvcreate' command"
      ;;
    26)
      counterLine=112
      print "error" "$code" "From remote machine, failed at 'mkfs' command"
      ;;
    27)
      counterLine=77
      print "error" "$code" "From remote machine, failed at 'pvcreate' command"
      ;;
    28)
      counterLine=8
      print "error" "$code" "From remote machine, too many lines in conf file"
      ;;
    29)
      counterLine=34
      print "error" "$code" "From remote machine, installation of 'nis' packages failed"
      ;;
    30)
      counterLine=42
      print "error" "$code" "From remote machine, failure editing NIS's domain name"
      ;;
    31)
      counterLine=17
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    32)
      counterLine=22
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    33)
      counterLine=38
      print "error" "$code" "From remote machine, too many lines in conf file"
      ;;
    34)
      counterLine=45
      print "error" "$code" "From remote machine, installation of 'portmap' package failed"
      ;;
    35)
      counterLine=60
      print "error" "$code" "From remote machine, installation of 'nis' package failed"
      ;;
    36)
      counterLine=11
      print "error" "$code" "From remote machine, specified route does not exist"
      ;;
    37)
      counterLine=13
      print "error" "$code" "From remote machine, specified route does not have the necessary permissions"
      ;;
    38)
      counterLine=31
      print "error" "$code" "From remote machine, installation of 'nfs-kernel-server' package failed"
      ;;
    39)
      counterLine=20
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    40)
      counterLine=48
      print "error" "$code" "From remote machine, failure creating the NFS table that holds the exports"
      ;;
    41)
      counterLine=52
      print "error" "$code" "From remote machine, failed to start the NFS service"
      ;;
    42)
      counterLine=42
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    43)
      counterLine=14
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    44)
      counterLine=18
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    45)
      counterLine=32
      print "error" "$code" "From remote machine, there are missing arguments in one of the lones of the conf file"
      ;;
    46)
      counterLine=57
      print "error" "$code" "From remote machine, installation of 'nfs-common' package failed"
      ;;
    47)
      counterLine=73
      print "error" "$code" "From remote machine, failure while mounting the remote directory"
      ;;
    48)
      counterLine=75
      print "error" "$code" "From remote machine, NFS shares have not been properly mounted"
      ;;
    49)
      counterLine=8
      print "error" "$code" "From remote machine, specified directory in conf file $3 does not exist"
      ;;
    50)
      counterLine=6
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    51)
      counterLine=60
      print "error" "$code" "From remote machine, too many lines in conf file"
      ;;
    52)
      counterLine=13
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    53)
      counterLine=17
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    54)
      counterLine=66
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    55)
      counterLine=76
      print "error" "$code" "From remote machine, installation of 'rsync' command was unsuccesful"
      ;;
    56)
      counterLine=33
      print "error" "$code" "From remote machine, client's directory does not seem to exist"
      ;;
    57)
      counterLine=57
      print "error" "$code" "From remote machine, periodicty time does not seem to be a number"
      ;;
    58)
      counterLine=54
      print "error" "$code" "From remote machine, periodicty time seems to be too small"
      ;;
    59)
      counterLine=89
      print "error" "$code" "From remote machine, 'rsync' command has gone wrong"
      ;;
    60)
      counterLine=12
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    61)
      counterLine=20
      print "error" "$code" "From remote machine, installation of 'portmap' service has gone wrong"
      ;;
    62)
      counterLine=12
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    63)
      counterLine=50
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    64)
      print "error" "$code" "From remote machine, total size wanted is too big for the volume group size"
      ;;
  esac
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
