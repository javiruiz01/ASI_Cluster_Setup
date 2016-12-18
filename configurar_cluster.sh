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
  print "info" "I'm in the mount function"
  if [[ -z data.tar ]]
  then
    rm data.tar
  fi
  cd remote_conf
  print "info" "Zipping files"
  tar -cf data.tar $2.sh $3 > /dev/null
  scp data.tar root@$1:~/ > /dev/null
  print "info" "Connecting via SSH"
  ssh -n root@$1 'tar -xvf data.tar && rm data.tar; ./'"$2"'.sh' 2>/dev/null
  # Ahora cogemos los codigos de errores
  code=$?
  case $code in
    0)
      # Todo a salido bien en a maquina remota, seguimos leyendo el fichero de 
      # configuracion
      print "info" "Next step"
      cd /home/practicas/cluster_configuration/
      ;;
    11)
      # MOUNT
      counterLine=9
      print "error" "$code" "From the remote machine, the conf file $3 has too many lines"
      ;;
    12)
      # MOUNT 
      counterLine=27
      print "error" "$code" "From the remote machine, mounting point does not seem to be empty"
      ;; 
    13)
      # MOUNT
      counterLine=32
      print "error" "$code" "From remote machine, device does not seems to exist"
      ;;
    14)
      # RAID
      counterLine=9
      print "error" "$code" "From remote machine, the conf file $3 seems to have too many lines"
      ;;
    15)
      # RAID
      counterLine=65
      print "error" "$code" "From remote machine, could not install 'mdadm' command"
      ;;
    16)
      # RAID
      counterLine=41
      print "error" "$code" "From remote machine, device doesn't seem to exist"
      ;;
    17)
      # RAID
      counterLine=43
      print "error" "$code" "From remote machine, device is not a block device"
      ;;
    18)
      # RAID
      counterLine=72
      print "error" "$code" "From remote machine, command 'mdadm' failed"      
      ;;
    19)
      # RAID
      counterLine=19
      print "error" "$code" "From remote machine, invalid RAID level"
      ;;
    20)
      # LVM
      counterLine=67
      print "error" "$code" "From remote machine, installation of 'lvm2' command has failed"
      ;;
    21)
      # LVM
      counterLine=34
      print "error" "$code" "From remote machine, one of the devices doesn't exist"
      ;;
    22)
      # LVM
      counterLine=55
      print "error" "$code" "From remote machine, total size seems to be too big for the machine"
      ;;
    23)
      # LVM
      counterLine=49
      print "error" "$code" "From remote machine, not enough lines in lvm.conf"
      ;;
    24)
      # LVM
      counterLine=102
      print "error" "$code" "From remote machine, failed at 'vgcreate' command"
      ;;
    25)
      # LVM
      counterLine=105
      print "error" "$code" "From remote machine, failed at 'lvcreate' command"
      ;;
    26)
      # LVM
      counterLine=112
      print "error" "$code" "From remote machine, failed at 'mkfs' command"
      ;;
    27)
      # LVM
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
      # NFS_SERVER
      counterLine=11
      print "error" "$code" "From remote machine, specified route does not exist"
      ;;
    37)
      # NFS_SERVER
      counterLine=13
      print "error" "$code" "From remote machine, specified route does not have the necessary permissions"
      ;;
    38)
      # NFS_SERVER
      counterLine=31
      print "error" "$code" "From remote machine, installation of 'nfs-kernel-server' package failed"
      ;;
    39)
      # NFS_SERVER
      counterLine=20
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    40)
      # NFS_SERVER
      counterLine=48
      print "error" "$code" "From remote machine, failure creating the NFS table that holds the exports"
      ;;
    41)
      # NFS_SERVER
      counterLine=52
      print "error" "$code" "From remote machine, failed to start the NFS service"
      ;;
    42)
      # NFS_CLIENT
      counterLine=42
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    43)
      # NFS_CLIENT
      counterLine=14
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    44)
      # NFS_CLIENT
      counterLine=18
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    45)
      # NFS_CLIENT
      counterLine=32
      print "error" "$code" "From remote machine, there are missing arguments in one of the lones of the conf file"
      ;;
    46)
      # NFS_CLIENT
      counterLine=57
      print "error" "$code" "From remote machine, installation of 'nfs-common' package failed"
      ;;
    47)
      # NFS_CLIENT
      counterLine=73
      print "error" "$code" "From remote machine, failure while mounting the remote directory"
      ;;
    48)
      # NFS_CLIENT
      counterLine=75
      print "error" "$code" "From remote machine, NFS shares have not been properly mounted"
      ;;
    49)
      # BACKUP_SERVER
      counterLine=8
      print "error" "$code" "From remote machine, specified directory in conf file $3 does not exist"
      ;;
    50)
      # BACKUP_SERVER
      counterLine=6
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    51) 
      # BACKUP_CLIENT
      counterLine=60
      print "error" "$code" "From remote machine, too many lines in conf file"
      ;;
    52)
      # BACKUP_CLIENT
      counterLine=13
      print "error" "$code" "From remote machine, invalid IP, at least one number is bigger than 255"
      ;;
    53)
      # BACKUP_CLIENT
      counterLine=17
      print "error" "$code" "From remote machine, invalid IP, not everything are numbers"
      ;;
    54)
      # BACKUP_CLIENT
      counterLine=66
      print "error" "$code" "From remote machine, incorrect number of lines in conf file"
      ;;
    55)
      # BACKUP_CLIENT
      counterLine=76
      print "error" "$code" "From remote machine, installation of 'rsync' command was unsuccesful"
      ;;
    56)
      # BACKUP_CLIENT
      counterLine=33
      print "error" "$code" "From remote machine, client's directory does not seem to exist"
      ;;
    57)
      # BACKUP_CLIENT
      counterLine=57
      print "error" "$code" "From remote machine, periodicty time does not seem to be a number"
      ;;
    58)
      # BACKUP_CLIENT
      counterLine=54
      print "error" "$code" "From remote machine, periodicty time seems to be too small"
      ;;
    59)
      # BACKUP_CLIENT
      counterLine=89
      print "error" "$code" "From remote machine, 'rsync' command has gone wrong"
      ;;
    60)
      # NIS_SERVER
      counterLine=12
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    61)
      # NIS_SERVER
      counterLine=20
      print "error" "$code" "From remote machine, installation of 'portmap' service has gone wrong"
      ;;
    62)
      # BACKUP_SERVER
      counterLine=12
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
      ;;
    63)
      # RAID
      counterLine=50
      print "error" "$code" "From remote machine, the configuration file $3 seems to be empty"
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
  # Ejecutamos como superusuario, no hace falta comprobar permisos
  #if [[ ! -r $CONF ]]
  #then
  #  print "error" "6" "Looks like I can't read the '$CONF' file"
  #fi
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
