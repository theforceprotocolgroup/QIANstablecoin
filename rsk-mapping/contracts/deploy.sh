#!/bin/bash


echo "MAIN_OWNER_PRIVATE_KEY: ${MAIN_OWNER_PRIVATE_KEY}"
echo "SIDE_OWNER_PRIVATE_KEY: ${SIDE_OWNER_PRIVATE_KEY}"
echo "MAIN_NETWORK_HOST: ${MAIN_NETWORK_HOST}"
echo "SIDE_NETWORK_HOST: ${SIDE_NETWORK_HOST}"

truffle compile

truffle exec script/deploy-main.js --network main
truffle exec script/deploy-side.js --network side

node script/generate-output-files.js