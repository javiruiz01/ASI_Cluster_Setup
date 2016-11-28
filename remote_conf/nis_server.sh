#! /bin/bash

lineCounter=0
while read -r line
do
  lineCounter=$((lineCounter + 1))
  domainName=$line
  [[ $lineCounter -gt 1 ]] && exit 28 
done < "nis_server.conf"

# Check for installation of the requiered packages
which 

exit 0
