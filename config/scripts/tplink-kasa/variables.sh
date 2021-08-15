#!/bin/bash

#kasa cridentials
USER_NAME=YOUR_KASA_LOGIN
PASSWORD=YOUR_KASA_PASSWORD
#api url can be taken from kasa-devices but this should also work, I'd assume depending on world region it may be different
API_URL=https://aps1-wap.tplinkcloud.com
#a uuidv4, can be generated online (for example here https://www.uuidgenerator.net/version4)
TERMINAL_UUID=UUID_V4
#time in seconds after which token needs to be refreshed
TOKEN_EXPIRATION=3600