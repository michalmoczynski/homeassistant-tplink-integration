#!/bin/bash

source /config/scripts/tplink-kasa/variables.sh
source /config/scripts/tplink-kasa/getTokenAge.sh
TOKEN=$(cat /config/scripts/tplink-kasa/kasa-token)
#IN_PROGRESS=$(cat get-devices-in-progress)

#echo "IN_PROGRESS: {$IN_PROGRESS}"

generate_post_data()
{
  cat <<EOF
{
	"method": "getDeviceList",
	"params": {
		"token": "$TOKEN"
	}
}
EOF
}

if [ "$TOKEN_AGE" -gt "$TOKEN_EXPIRATION" ]; then
	/config/scripts/tplink-kasa/getToken.sh
fi

devices=$(curl -s \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "$API_URL")

writeToFile=/config/scripts/tplink-kasa/kasa-devices
#echo "devices: {$devices}"
#msg=$(cat ./kasa-devices | jq -r  '.msg')

#echo "msg: {$msg}"

#FILE=./get-devices-in-progress
#if test -f "$FILE"; then
#    echo "already tried getting new token, something else must be wrong"
#else
#	if [ "$msg" = "Token expired" ]; then
#		echo "token expired... getting new token"
#	  ./getToken.sh
#		echo  "true" > "./get-devices-in-progress"
#	  ./getDevices.sh
#	else
		echo  "${devices}" > "$writeToFile"
#	fi
#fi