#!/bin/bash

id="$1"
pass="$2"
downloadfolder="$3"

case "$4" in
	*.dlc)
		links=$(curl -s 'http://dcrypt.it/decrypt/paste' --data-urlencode "content@$4" |jq -r .success.links|grep -Po ' "\K[^"]*')
		;;
	*.links)
		links=$(cat $4)
		;;
	*.txt)
		links=$(cat $4)
		;;
	*)
		echo $"Usage: $0 { dlc-File | list-File }"
		echo "A File containing a list of URLs"
		exit 1
esac

mkdir -p $downloadfolder
cd $downloadfolder

for i in $links;
do
	JSON=$(curl -s "https://api.premiumize.me/pm-api/v1.php?method=directdownloadlink&params\[login\]=$id&params\[pass\]=$pass&params\[link\]=$i")

	STATUS=$(echo $JSON | jq -r .status)
	MESSAGE=$(echo $JSON | jq -r .statusmessage)

	if [ $STATUS == 200 ] 
	then
		LOCATION=$(echo $JSON | jq -r .result.location)
		NAME=$(echo $JSON | jq -r .result.filename)

		echo $NAME
		wget -c -O $NAME $LOCATION
	else
		echo "Error:" $MESSAGE
	fi
done

# Extract downloaded files
files=$(ls | awk '(!/extract/ && (!/part/ || /part1./ || /part01./))')

mkdir -p extract

for file in $files;
do              
        unar -f -o extract $file
done
