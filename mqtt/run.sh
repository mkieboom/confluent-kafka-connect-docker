#!/bin/bash

# Create the folders
mkdir -p ./mosquitto/config
mkdir -p ./mosquitto/data
mkdir -p ./mosquitto/log

# Get the mosquito config file
wget https://raw.githubusercontent.com/eclipse/mosquitto/master/mosquitto.conf -P ./mosquitto/config/ -nc

# Start docker
docker-compose up

# Example mosquitto pub and sub commands:

# Pub:
# mosquitto_pub -h localhost -p 1883 -t confluent/mqtt-connect-demo -m "HelloWorld"

# Sub:
# mosquitto_sub -h localhost -p 1883 -v -t confluent/mqtt-connect-demo