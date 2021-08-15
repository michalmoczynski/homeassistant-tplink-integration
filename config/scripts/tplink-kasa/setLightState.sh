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
            on)              ON_OFF=${VALUE} ;;
            sat)    SATURATION=${VALUE} ;;
            hue)    HUE=${VALUE} ;;
            ctemp)    COLOR_TEMP=${VALUE} ;;
            b)    BRIGHTNESS=${VALUE} ;;
            id)    DEVICE_ID=${VALUE} ;;
            t)    TRANSITION_TIME=${VALUE} ;;
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
		"deviceId": "$DEVICE_ID",
		"requestData": {
			"smartlife.iot.smartbulb.lightingservice": {
                "transition_light_state":{
                    "ignore_default":1,
                    "mode":"normal",
EOF
if [ ! -z "$BRIGHTNESS" ]; then
  cat <<EOF
                    "brightness":$BRIGHTNESS,
EOF
fi                	
if [ ! -z "$COLOR_TEMP" ]; then
  cat <<EOF
                    "color_temp":$COLOR_TEMP,
EOF
fi                	
if [ ! -z "$HUE" ]; then
  cat <<EOF
                    "hue":$HUE,
EOF
fi                	
if [ ! -z "$ON_OFF" ]; then
  cat <<EOF
                    "on_off":$ON_OFF,
EOF
fi                	
if [ ! -z "$SATURATION" ]; then
  cat <<EOF
                    "saturation":$SATURATION,
EOF
fi                	
if [ ! -z "$TRANSITION_TIME" ]; then
  cat <<EOF
                    "transition_period":$TRANSITION_TIME
EOF
  else
  cat <<EOF
                    "transition_period":1500
EOF
fi                	
	cat <<EOF                
									}
			}
		},
		"token": $TOKEN
	}
}
EOF
}

generate_sensor_data()
{
  cat <<EOF
  $state_saturation,$state_brightness,$state_hue,$state_on,$state_temp
EOF
}


if [ "$TOKEN_AGE" -gt "$TOKEN_EXPIRATION" ]; then
	/config/scripts/tplink-kasa/getToken.sh
fi

setDeviceStatus=$(curl -s \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "$API_URL")

#echo  "${setDeviceStatus}"

state_saturation=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.saturation' <<< "${setDeviceStatus}" ) 
state_brightness=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.brightness' <<< "${setDeviceStatus}" ) 
state_hue=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.hue' <<< "${setDeviceStatus}" ) 
state_on=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.on_off' <<< "${setDeviceStatus}" ) 
state_temp=$( jq -r  '.result.responseData."smartlife.iot.smartbulb.lightingservice".transition_light_state.color_temp' <<< "${setDeviceStatus}" ) 

sensorFile=/config/scripts/tplink-kasa/devices/$DEVICE_ID.txt
rm /config/scripts/tplink-kasa/devices/$DEVICE_ID
echo  "$(generate_sensor_data)" > "$sensorFile"

echo "status: $setDeviceStatus"
echo "---"
echo "sensor: $(generate_sensor_data)"
