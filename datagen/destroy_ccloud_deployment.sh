#!/bin/bash

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ccloud_library.sh

# Load the Confluent Cloud library
source ./ccloud_library.sh

# Stop the local running Connect framework
docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml down
docker volume prune -f

export QUIET=false

export SERVICE_ACCOUNT_ID=92758
export ENVIRONMENT_NAME=mkieboom-cicd-env
export CLUSTER_NAME=mkieboom-cicd-gcp
export CLUSTER_CLOUD=gcp
export CLUSTER_REGION=europe-west4

export SCHEMA_REGISTRY_CLOUD=gcp
export SCHEMA_REGISTRY_GEO=eu

export CLIENT_CONFIG=kafka.config

# Destroy the Confluent Cloud stack
ccloud::destroy_ccloud_stack $SERVICE_ACCOUNT_ID

rm -rf delta_configs/
rm -rf ccloud_kafka_examples/
rm -rf cp-all-in-one/
