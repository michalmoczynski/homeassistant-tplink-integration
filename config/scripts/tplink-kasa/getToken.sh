#!/bin/bash
source /config/scripts/tplink-kasa/variables.sh

generate_post_data()
{
  cat <<EOF
{
        "method": "login",
        "params": {
                "appType": "Kasa_Android",
                "cloudUserName": "$USER_NAME",
                "cloudPassword": "$PASSWORD",
                "terminalUUID": "$TERMINAL_UUID"
        }
}  
EOF
}

token=$(curl -s \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "$API_URL" | jq -r '.result.token')

echo "getting new token"
rm /config/scripts/tplink-kasa/kasa-token
writeToFile=/config/scripts/tplink-kasa/kasa-token

echo  "${token}" > "$writeToFile"
