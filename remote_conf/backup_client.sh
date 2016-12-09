#! /bin/bash

function check_ip {
  if [[ $server =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $server
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      echo -e "[\e[32mINFO\e[0m] Valid IP"
    else
      exit 52
    fi
    IFS=$OIFS
  else
    exit 53
  fi
}

# Formato del fichero de configuracion
#   ruta-del-directorio-del-que-se-desea-hacer-backup
#   direccion-del-servidor-de-backup
#   ruta-de-directorio-destino-del-backup
#   periodicidad-del-backup-en-horas
echo "HOLITA QUE TAL"
lineCounter=0
while read -r line
do
  # Este es nuestro directorio del que queremos hacer backup
  if [[ $lineCounter -eq 0 ]] 
  then
    directory=$line
    [[ ! -d $directory ]] && exit 56
    echo -e "[\e[32mINFO\e[0m] This is our working directory: $directory"
  elif [[ $lineCounter -eq 1 ]] 
  then 
    server=$line 
    check_ip "$server"
    echo -e "[\e[32mINFO\e[0m] This is the IP: $server"
  elif [[ $lineCounter -eq 2 ]]
  then
    serverRoute=$line 
    echo -e "[\e[32mINFO\e[0m] This is our server route: $serverRoute"
  elif [[ $lineCounter -eq 3 ]]
  then
    # Tenemos que comprobar que la periodicidad es un numero
    delorean=$line 
    #[[ $delorean == ?(-)+([0-9]) ]] && exit 57
    echo -e "[\e[32mINFO\e[0m] This is our delorean: $delorean"
  else
    exit 51 
  fi
  lineCounter=$((lineCounter+1))
done < "backup_client.conf"

# Comprobamos que las lineas eran las correctas
[[ $lineCounter -ne 4 ]] && exit 54

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
rsync -a $directory root@$server:$serverRoute
[[ $? -ne 0 ]] && exit 56

# Periodicidad del backup en horas
rsyncRoute=`which rsync`
touch $pwd/rsync.sh
chmod +x $pwd/rsync.sh
echo "$rsyncRoute -a $directory root@$server:$serverRoute" >> $pwd/rsync.sh
cat $pwd/rsync.sh
(crontab -l 2>/dev/null; echo "* */$delorean * * * $pwd/rsync.sh") | crontab -

exit 0
