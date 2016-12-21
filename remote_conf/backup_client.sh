#! /bin/bash

function check_ip {
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $1
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      echo -e "[\e[32mINFO\e[0m] Valid IP: $server"
    else
      exit 52
    fi
    IFS=$OIFS
  else
    exit 53
  fi
}

# Formato del fichero de configuracion
#   ruta-del-directorio-del-que-se-desea-hacer-backup <-- LOCAL
#   direccion-del-servidor-de-backup
#   ruta-de-directorio-destino-del-backup <-- REMOTO
#   periodicidad-del-backup-en-horas
lineCounter=0
while read -r line
do
  # Este es nuestro directorio del que queremos hacer backup
  if [[ $lineCounter -eq 2 ]] 
  then
    directory=$line
    [[ ! -d $directory ]] && exit 56
    echo -e "[\e[32mINFO\e[0m] This is the server directory: $directory"
  elif [[ $lineCounter -eq 1 ]] 
  then 
    server=$line 
    check_ip "$server"
  elif [[ $lineCounter -eq 0 ]]
  then
    serverRoute=$line 
    #[[ ! -d $serverRoute ]] && exit 56
    echo -e "[\e[32mINFO\e[0m] This is our local route: $serverRoute"
  elif [[ $lineCounter -eq 3 ]]
  then
    # Tenemos que comprobar que la periodicidad es un numero
    delorean=$line 
    if [[ $delorean -lt 24 ]]
    then
      if [[ $delorean -gt 0 ]]
      then
        echo -e "[\e[32mINFO\e[0m] Schedule time: $delorean hour(s)"
      else
        exit 58
      fi
    else
      exit 57 
    fi
  else
    exit 51 
  fi
  lineCounter=$((lineCounter+1))
done < "backup_client.conf"

# Comprobamos que las lineas eran las correctas
[[ $lineCounter -ne 4 ]] && exit 54

# Tecnicamente ya esta instalado rsync en las maquinas que nos dan, pero lo
# comprobamos igualmente
which rsync > /dev/null
if [[ $? -ne 0 ]] 
then
  echo -e "[\e[32mINFO\e[0m] Installing command 'rsync'"
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m rsync > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 55
  echo -e "[\e[32mINFO\e[0m] Installed correctly"
else
  echo -e "[\e[32mINFO\e[0m] Command 'rsync' exists, continuing"
fi

# Para la utilizacion del comando rsync, se necesita que esten ya puestas Kpriv y Kpubl
# En el enunciado de la practica pone:
# "se podra asumir que un servidor de ssh esta presente en todas las maquinas y que el 
#  usuario root puede conectarse de unas a otras sin tener que insertar contrasena"

echo 'rsync'" -a $directory root@$server:$serverRoute"
rsync -a $directory root@$server:$serverRoute > /dev/null 2> /dev/null
[[ $? -ne 0 ]] && exit 59

# Periodicidad del backup en horas
rsyncRoute=`which rsync`
if [[ ! -e $PWD/rsync.sh ]] 
then
  touch $PWD/rsync.sh
  echo '#! /bin/bash' >> $PWD/rsync.sh
fi
# chmod +x $PWD/rsync.sh somos root, no nos hacen falta permisos como tal

if [[ -n "`cat $PWD/rsync.sh | grep "$rsyncRoute -a $directory root@$server:$serverRoute"`" ]] 
then
  echo -e "[\e[32mINFO\e[0m] Already in $PWD/rsync.sh file"
else
  echo "$rsyncRoute -a $directory root@$server:$serverRoute" >> $PWD/rsync.sh
fi

if [[ ! -n "`crontab -l | grep $PWD/rsync.sh`" ]]
then
  (crontab -l 2>/dev/null; echo "* */$delorean * * * $PWD/rsync.sh") | crontab -
  if [[ $delorean -eq 1 ]]
  then
    echo -e "[\e[32mINFO\e[0m] Crontab has been installed, it will execute every $delorean hour"
  else
    echo -e "[\e[32mINFO\e[0m] Crontab has been installed, it will execute every $delorean hours"
  fi
else
  echo -e "[\e[32mINFO\e[0m] Crontab was already installed"
fi

exit 0
