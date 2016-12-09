#! /bin/bash

lineCounter=0
while read -r line
do
  lineCounter=$((lineCounter + 1))
  domainName=$line
  [[ $lineCounter -gt 1 ]] && exit 28 
  echo -e "[\e[32mINFO\e[0m] Domain name is: $domainName"
done < "nis_server.conf"

# Check for installation of the requiered packages
which rpcbind > /dev/null
if [[ $? -ne 0 ]] 
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get install portmap --no-install-recommends > /dev/null 2> /dev/null
  # Condicion, ver si se ha instalado bien
  echo -e "[\e[32mINFO\e[0m] Command 'portmap' installed correctly"
else
  echo -e "[\e[32mINFO\e[0m] Command is already installed, continuing"
fi

# echo -e "[\e[32mINFO\e[0m] Updating 'portmap' defaults"
# solo parece que da problemas, vamos a intentar seguir sin este comando
# update-rc.d portmap defaults 10
# Condicion

which ypserv > /dev/null
if [[ $? -ne 0 ]] 
then
  export DEBIAN_FRONTEND=noninteractive
  apt-get -qq install nis --no-install-recommends > /dev/null 2> /dev/null
  [[ $? -ne 0 ]] && exit 29
  echo -e "[\e[32mINFO\e[0m] Commands for 'NIS_server' installation went well, continuing"
else
  echo -e "[\e[32mINFO\e[0m] Necessary commands for 'NIS_server' are already installed, continuing"
fi

# Now we edit the domain name 
nisdomainname $domainName
[[ $? -ne 0 ]] && exit 30

if [[ -n "`grep "NISSERVER=false" /etc/default/nis`" ]]
then
  sed -i 's/NISSERVER=false/NISSERVER=master/g' /etc/default/nis
fi

if [[ -n "`grep "NISCLIENT=true" /etc/default/nis`" ]]
then
  sed -i 's/NISCLIENT=true/NISCLIENT=false/g' /etc/default/nis
fi

# TODO: Pensar bien en si hay que hacer esto, por ahora se comenta
#sed -i 's/0.0.0.0/#0.0.0.0/g' /etc/ypserv.securenets

# Restart the portmap daemon
/etc/init.d/portmap restart

# Restart the NIS daemon
/etc/init.d/nis restart

# No seguimos avanzando, tecnicamente el servidor NIS ya esta creado

exit 0
