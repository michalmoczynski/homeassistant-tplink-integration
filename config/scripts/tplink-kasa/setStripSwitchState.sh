#!/bin/bash

source /config/scripts/tplink-kasa/variables.sh
source /config/scripts/tplink-kasa/getTokenAge.sh
TOKEN=$(cat /config/scripts/tplink-kasa/kasa-token)

#get parameters
for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            onoff)              ON_OFF=${VALUE} ;;
            stripid)    STRIP_ID=${VALUE} ;;
            plugid)    PLUG_ID=${VALUE} ;;
            *)   
    esac    


done
#

generate_post_data()
{
  cat <<EOF
{
	"method": "passthrough",
	"params": {
		"deviceId": "$STRIP_ID",
		"requestData": {
      "context": {
        "child_ids": [ "$PLUG_ID" ]
      },
      "system": {
        "set_relay_state": {
          "state": $ON_OFF
        }
      }
    },
    "token": "$TOKEN"
  }
}
EOF
}

generate_sensor_data()
{
  cat <<EOF
  $ON_OFF
EOF
}


if [ "$TOKEN_AGE" -gt "$TOKEN_EXPIRATION" ]; then
	/config/scripts/tplink-kasa/getToken.sh
fi

setDeviceStatus=$(curl -s \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "$API_URL")

#echo  "${setDeviceStatus}"

#state_on=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.on_off' <<< "${setDeviceStatus}" ) 

sensorFile=/config/scripts/tplink-kasa/devices/$PLUG_ID.txt
rm /config/scripts/tplink-kasa/devices/$PLUG_ID
echo  "$(generate_sensor_data)" > "$sensorFile"

echo "status: $setDeviceStatus"
echo "---"
echo "sensor: $(generate_sensor_data)"
