#!/bin/bash

source /config/scripts/tplink-kasa/variables.sh
source /config/scripts/tplink-kasa/getTokenAge.sh
TOKEN=$(cat /config/scripts/tplink-kasa/kasa-token)
DEVICE_ID=$1

generate_post_data()
{
  cat <<EOF
{
	"method": "passthrough",
	"params": {
		"deviceId": "$DEVICE_ID",
		"requestData": {
			"system": {
				"get_sysinfo": null
			},
			"emeter": {
				"get_realtime": null
			}
		},
		"token": "$TOKEN"
	}
}
EOF
}

if [ "$TOKEN_AGE" -gt "$TOKEN_EXPIRATION" ]; then
	/config/scripts/tplink-kasa/getToken.sh
fi

deviceStatus=$(curl -s \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "$API_URL")

echo  "$1 status: ${deviceStatus}"

#echo  "status: $(generate_post_data)"
