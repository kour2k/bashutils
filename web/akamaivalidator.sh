#!/bin/bash

# VARIABLES
listado="dominios.txt"
result="AKAMAIstatus.txt"
tmp=`mktemp -t akamai.XXXXXXXXX`
if [ $# != 0 ]; then
	echo "Usage: $0"
	exit 1
fi

if [ ! -e $listado ]; then
    exit 2
fi

while read -r line; do
	domain=$line
    nslookup $domain|grep edgekey.net > /dev/null
    if [ $? ]; then
		akamai="SECURE"
    else
        if [ $? ]; then
            nslookup $domain|grep edgesuite.net > /dev/null
            akamai="NON_SECURE"
        else
            akamai="NON_AKAMAI"
        fi
    fi
		ip=`nslookup $domain|grep Address|grep -v "#53"|awk '{print $2}'`
    curl -A "Mozilla/5.0" -s -I $domain |awk -v akamai=$akamai -v domain=$domain -v ip=$ip ' BEGIN{ RS="" }
            /200 OK/{ print akamai";"domain";"ip";"$2}
            /301 Moved Permanently/ { print akamai";"domain";"ip";"$2";"$8}
            /302 Moved Temporarily/ { print akamai";"domain";"ip";"$2";"$8}
            /400 Bad Request/ { print akamai";"domain";"ip";"$2";Not included on AKAMAIs configuration"}
            /503 Service Unavailable/ { print akamai";"domain";"ip";"$2"; WAF Configuration?" }
            ' >> $tmp
done < $listado
#close $inFile
mv $tmp $result
