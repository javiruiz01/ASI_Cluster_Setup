#! /bin/bash

# Formato fichero:
#   nombre-dominio-nis
#   servicio-nis-al-que-se-desea-conectar (IP)

function check_ip {
  ip=$1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
  then
    OIFS=$IFS
    IFS="."
    set -- $ip
    if [[ $1 -le 255 && $2 -le 255 && $3 -le 255 && $4 -le 255 ]]
    then
      echo -e "[\e[32mINFO\e[0m] Valid IP"
    else 
      exit 31
    fi
    IFS=$OIFS
  else
    echo -e "[\e[31mERROR\e[0m] Not a valid IP"
    exit 32
  fi
}

counterLine=0
while read -r line
do
  counterLine=$((counterLine+1))
  [[ $counterLine -eq 1 ]] && domainName=$line
  if [[ $counterLine -eq 2 ]]
  then
    ip=$line
    check_ip "$ip"
  fi
done < "nis_client.conf"

[[ $counterLine -gt 2 ]] && exit 33

which rpcbind > /dev/null
if [[ $? -ne 0 ]] 
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install -m portmap --no-install-recommends > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 34
else
  echo -e "[\e[32mINFO\e[0m] Command is already installed, continuing"
fi

# Igual que para el server
# update-rc.d portmap defaults 10

# Aunque no sea el que vayamos a utilizar, si este no esta instalado,
# ninguno lo está, por lo que tenemos que instalarlo
which ypserv > /dev/null
if [[ $? -ne 0 ]]
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install nis --no-install-recommends > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 35
else
  echo -e "[\e[32mINFO\e[0m] Command is already installed, continuing"
fi
/usr/sbin/ypbind start
# Mirar comprobaciones fancies para poner aqui
# porque a lo mejor puede que ya exista
#echo "domain $domainName server $ip" >> /etc/yp.conf
echo "ypserver $ip" >> /etc/yp.conf

echo "$domainName" > /etc/defaultdomain
# Despues de tutoria con latorre
if [[ ! -n "`grep "nis" /etc/nsswitch.conf`" ]]
then
  sed -i 's/passwd:         compat/passwd:         nis compat/g' /etc/nsswitch.conf
  sed -i 's/group:          compat/group:          nis compat/g' /etc/nsswitch.conf
  sed -i 's/shadow:         compat/shadow:         nis compat/g' /etc/nsswitch.conf
fi

# For security reasons
echo "portmap : $ip" > /etc/hosts.allow

if [[ -n "`grep "+::::::" /etc/passwd`" ]]
then
  echo "+::::::" > /etc/passwd
fi
if [[ -n "`grep "+::::::" /etc/group`" ]]
then
  echo "+:::" > /etc/group
fi
if [[ -n "`grep "+::::::" /etc/shadow`" ]]
then
  echo "+::::::::" > /etc/shadow
fi
# End tutorial

# /usr/sbin/ypinit -m

echo -e "[\e[32mINFO\e[0m] Restarting yp service"
#/usr/lib/netsvc/yp/ypstop
#/usr/lib/netsvc/yp/ypstart
service nis restart

exit 0
