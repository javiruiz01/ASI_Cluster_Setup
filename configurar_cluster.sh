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
  tar -cf data.tar $2.sh $3 > /dev/null
  scp data.tar root@$1:~/ > /dev/null
  print "info" "Connecting via SSH"
  ssh -n root@$1 'tar -xvf data.tar && rm data.tar; ./'"$2"'.sh'
  # Ahora cogemos los codigos de errores
  code=$?
  case $code in
    0)
       print "info" "Next step"
       cd /home/practicas/cluster_configuration/
       ;;
    11)
      counterLine=9
      print "error" "$code" "From the remote machine, the conf file '$3' seems to have some errors"
      ;;
    12)
      counterLine=29
      print "error" "$code" "From the remote machine, mounting point does not seem to be empty"
      ;; 
    13)
      counterLine=37
      print "error" "$code" "From remote machine, device does not seems to exist"
      ;;
    14)
      counterLine=10
      print "error" "$code" "From remote machine, the conf file '$3' seems to have some errors"
      ;;
    15)
      counterLine=48
      print "error" "$code" "From remote machine, could not install 'mdadm' command"
      ;;
    16)
      counterLine=31
      print "error" "$code" "From remote machine, device doesn't seem to exist"
      ;;
    17)
      counterLine=33
      print "error" "$code" "From remote machine, device is not a block device"
      ;;
    18)
      counterLine=69
      print "error" "$code" "From remote machine, command 'mdadm' has gone wrong"      
      ;;
    19)
      counterLine=19
      print "error" "$code" "From remote machine, invalid RAID level"
      ;;
    20)
      counterLine=86
      print "error" "$code" "from remote machine, installation of 'lvm' command has failed"
      ;;
    22)
      counterLine=25
      print "error" "$code" "From remote machine, total size seems to be too big for the machine"
      ;;
    23)
      counterLine=61
      print "error" "$code" "From remote machine, not enough lines in lvm.conf"
      ;;
    24)
      counterLine=102
      print "error" "$code" "From remote machine, failed at 'vgcreate' command"
      ;;
    25)
      counterLine=108
      print "error" "$code" "From remote machine, failed at 'lvcreate' command"
      ;;
    26)
      counterLine=112
      print "error" "$code" "From remote machine, failed at 'mkfs' command"
      ;;
    27)
      counterLine=97
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
      counterLine=34
      print "error" "$code" "From remote machine, installation of 'nfs-kernel-server' package failed"
      ;;
    39)
      counterLine=20
      print "error" "$code" "From remote machine, too many lines in conf file"
      ;;
    40)
      counterLine=61
      print "error" "$code" "From remote machine, failed to create the NFS table"
      ;;
    41)
      counterLine=65
      print "error" "$code" "From remote machine, failed to start the NFS service"
      ;;
    42)
      counterLine=41
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    43)
      counterLine=13
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    44)
      counterLine=17
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    45)
      counterLine=31
      print "error" "$code" "From remote machine, there are missing arguments in a line at the conf file"
      ;;
    46)
      counterLine=55
      print "error" "$code" "From remote machine, installation of 'nfs-common' package failed"
      ;;
    47)
      counterLine=70
      print "error" "$code" "From remote machine, failure while mounting the remote directory"
      ;;
    48)
      counterLine=72
      print "error" "$code" "From remote machine, NFS shares have not been properly mounted"
      ;;
    49)
      counterLine=8
      print "error" "$code" "From remote machine, specified directory in conf file does not exist"
      ;;
    50)
      counterLine=6
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    51) 
      counterLine=13
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    52)
      counterLine=17
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
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
    print "info" "Beginning new line of 'fichero_configuracion': \n\t $line"
    #print "info" "We are going to be using this line: $line"
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
    if [[ ! -r remote_conf/$name.sh ]]
    then
      print "error" "8" "Service $name does not seem to exist"
    fi
    if [[ "$service" != *".conf" ]]
    then
      print "error" "9" "Format not accepted in line $counterLine"
    else
      print "info" "Valid service: $service"
    fi
    check_execute "remote_conf/$name.sh"
    setUp "$ip" "$name" "$service" 
  done < $CONF
}

main "$@"
