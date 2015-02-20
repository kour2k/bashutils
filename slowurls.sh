#!/bin/bash

if [ $# != 4 ]; then
	echo "Usage: $0 file info_time warning_time fatal_time" || true
        exit 1
fi

##
## I asume that Time is in Time:XXXX format and it is in 10th position (15th after editing it)
##

## Var declaration
file=$1

tail -f  $file|stdbuf -o0 sed 's/:/ /g'|awk -v info="$2" -v warning="$3" -v fatal="$4" '
	info    < $15 && $15 < warning {print "\033[0;34m" $10 "- " $15  "\033[0m" }
	warning < $15 && $15 < fatal   {print "\033[1;33m" $10 "- " $15"\033[0m"} 
	fatal   < $15                   {print "\033[1;31m" $10 "- " $15"\033[0m" }'

