
## _Integration between tp link devices and Home Assistant using Kasa Cloud API_

If you found that yout tp link lights, strip or socket don't work anymore with local API (after tp link updated their firmware) this may be a good solution for you.
It utilizes Kasa API - the same way tp link Kasa application updates your devices' states. This means that it's a cloud based solution. It requires you to have a Kasa account and your devices set in there - you can do it using tp link Kasa mobile app.
## Features

- Allows to turn on/off ligts
- Allows to change brightness of the light
- Allows to change hue and saturation of the light
- Allows to change a temperature of the lighy

## How does it work

Kasa Cloud API allows you to controll all the devices that you added to your Kasa app. You can try it yourself sending a POST request to kasa cloud server. 
First you need to send your login and password to receive a token:
```yaml
curl --location --request POST 'https://wap.tplinkcloud.com' \
--header 'Content-Type: application/json' \
--data-raw '{
	"method": "login",
	"params": {
		"appType": "Kasa_Android",
		"cloudUserName": "YOUR_KASA_LOGIN",
		"cloudPassword": "YOUR_KASA_PASSWORD",
		"terminalUUID": "GENERATE_A_UUID_V4"
	}
}'
```
Kasa Cloud server responds with a token that can be used for authentication on all the other requests.
Below I will list some of the cloud requests I found so far.

- getDeviceList - received details about all the devices set in Kasa application.
```yaml
curl --location --request POST 'https://wap.tplinkcloud.com' \
--header 'Content-Type: application/json' \
--data-raw '{
	"method": "getDeviceList",
	"params": {
		"token": "TOKEN_RECEIVED_FROM_KASAS"
	}
}'
```
- passthrough / smartlife.iot.smartbulb.lightingservice - change light settings
```yaml
curl --location --request POST 'https://wap.tplinkcloud.com' \
--header 'Content-Type: application/json' \
--data-raw '{
	"method": "passthrough",
	"params": {
		"deviceId": "DEVICE_ID",
		"requestData": {
			"smartlife.iot.smartbulb.lightingservice": {
                "transition_light_state":{
                    "brightness":255,
                    "color_temp":0,
                    "hue":0,
                    "ignore_default":1,
                    "mode":"normal",
                    "on_off":1,
                    "saturation": 100,
                    "transition_period":1000
                }
			}
		},
		"token": "TOKEN_RECEIVED_FROM_KASAS"
	}
}'
```
Parameters:
- brightness: 0-255
- color_temp: for KL130 it's between 9500 (cool) 2500 (warm)
- hue: 0-360
- saturation: 0-100

> Note: An easy way to see ranges of parametrers is to change settings in your Kasa mobile app and then check device status with the POST request (see below)

- passthrough / with deviceId - get device status
```yaml
curl --location --request POST 'https://wap.tplinkcloud.com' \
--header 'Content-Type: application/json' \
--data-raw '{
	"method": "passthrough",
	"params": {
		"deviceId": "DEVICE_ID",
		"requestData": {
			"system": {
				"get_sysinfo": null
			},
			"emeter": {
				"get_realtime": null
			}
		},
		"token": "TOKEN_RECEIVED_FROM_KASAS"
	}
}'
```
As a response Kasa Cloud sends details about the device configuration.

All those requests are utilized in the bash scripts to set light parameters and receive it's current settings.
To speed up things token is being saved in a file called `kasa-token`
## Installation

- to start using the scripts simply copy the files to your config folder (you can use samba plugin to do it)
- update `\config\scripts\tplink-kasa\variables.sh` file with your details.
- check the paths - the scripts are tested on Home Assistant docker that's why in the bash scripts the parhs to load and write files are looking something like `/config/scripts/tplink-kasa/...` if you are not using docker and your absolute paths are different you may need to change it the bash scripts and configuration file.
- update configuration.yaml - attached example has a single light set (YOUR_LIGHT_ID needs to be updated), accomodate those settings into your configuration.yaml
-- it calls shell commands that send requests to Kasa CLoud to update settings
-- it has sensors set that read current state of the light from the file being created after getting Kasa Cloud response
-- allowlist_external_dirs is being used to allow file sensors to work


## Note

Please be aware that I am not an advanced linux user, some things may look clunky for adcanced users. If you find some things may be done better or in a more flexible way please let me know! I'm happy to make things better.

## Useful links

- Joshua's Docs  - https://docs.joshuatz.com/random/tp-link-kasa/ - it was very useful to get some of the requests 
- UUID_v4 generator - https://www.uuidgenerator.net/version4
- HLS picker - https://hslpicker.com/ - easy way to generate your color (be aware that brightness is from 0-255 in Kasa Cloud and from 0-100 in hls picker)
- Security analysis of Kasa devices by Andrew Halterman - https://lib.dr.iastate.edu/cgi/viewcontent.cgi?article=1424&context=creativecomponents - very insightful document with bunch of API requests listed (dated 2019)

## License

MIT

