#!/bin/bash

CWD=$(cd `dirname $0` && pwd);

node ./src/federator.js ${CWD}/server-conf.json 0
