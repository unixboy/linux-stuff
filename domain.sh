#!/bin/bash
_dom=$@
 
# Die if no domains are given
[ $# -eq 0 ] && { echo "Usage: $0 domain1.com domain2.com ..."; exit 1; }
for d in $_dom
do
        _ip=$(host $d | grep 'has add' | head -1 | awk '{ print $4}')
        [ "$_ip" == "" ] && { echo "Error: $d is not valid domain or dns error."; continue; }
        echo "Getting information for domain: $d [ $_ip ]..."
        whois "$_ip" | egrep -w ':network:Network-Name:|:OrgName:|City:|Country:|OriginAS:|NetRange:'
        echo ""
done
