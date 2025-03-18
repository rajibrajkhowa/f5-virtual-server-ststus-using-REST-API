#!/bin/bash

# Variables
F5_USER=$1
F5_HOST=$2
F5_PASS=$(<password.txt)
VIRTUAL_SERVER=$3

# Function to get the status of a virtual server
get_virtual_server_status() {
    curl -sk -u $F5_USER:$F5_PASS \
    -H "Content-Type: application/json" \
    -X GET "https://$F5_HOST/mgmt/tm/ltm/virtual/$VIRTUAL_SERVER/stats"
}

# Call the function
get_virtual_server_status >> temp.txt

VS_DESTINATION=$(cat temp.txt | jq '.entries[].nestedStats.entries | ."destination"' | jq '.description' | tr -d '"')
VS_AVAILABILITY=$(cat temp.txt | jq '.entries[].nestedStats.entries | ."status.availabilityState"' | jq '.description' | tr -d '"')
VS_STATE=$(cat temp.txt | jq '.entries[].nestedStats.entries | ."status.enabledState"' | jq '.description' | tr -d '"')

jq -nc \
 --arg lb_host "$F5_HOST"\
 --arg vs "$VIRTUAL_SERVER" \
 --arg vs_dest "$VS_DESTINATION" \
 --arg vs_availability "$VS_AVAILABILITY" \
 --arg vs_state "$VS_STATE" \
 '{
    "LB HOST": $lb_host,
    "VS": $vs,
	"VS_DESTINATION": $vs_dest,
	"VS_AVAILABILITY": $vs_availability,
    "VS_STATE": $vs_state
  }'
 rm temp.txt
