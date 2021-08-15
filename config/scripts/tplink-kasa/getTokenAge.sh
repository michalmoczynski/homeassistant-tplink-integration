#!/bin/bash

TOKEN_AGE="$(( $(date +"%s") - $(stat -c "%Y" /config/scripts/tplink-kasa/kasa-token) ))"