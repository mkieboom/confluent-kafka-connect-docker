#!/bin/bash


# Function to create a kafka avro console consumer
function create_kafka_avro_console_consumer {
  TOPICNAME=$1
  FILENAME=$2

  cat <<EOF > ${FILENAME}
kafka-avro-console-consumer \
  --bootstrap-server ${BOOTSTRAP_SERVERS} \
  --consumer.config $CLIENT_CONFIG \
  --property basic.auth.credentials.source=USER_INFO \
  --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
  --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
  --topic ${TOPICNAME}
EOF

  chmod +x ${FILENAME}
}  

# Function to create a kafka avro console consumer reading form beginning
function create_kafka_avro_console_consumer_frombeginning {
  TOPICNAME=$1
  FILENAME=$2

  cat <<EOF > ${FILENAME}
kafka-avro-console-consumer \
  --bootstrap-server ${BOOTSTRAP_SERVERS} \
  --consumer.config $CLIENT_CONFIG \
  --property basic.auth.credentials.source=USER_INFO \
  --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
  --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
  --from-beginning \
  --topic ${TOPICNAME}
EOF

  chmod +x ${FILENAME}
}  

# Download the latest ccloud_library shell script
#curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh > ccloud_library.sh

# Load the Confluent Cloud library
source ./ccloud_library.sh

# Create a Confluent Cloud stack

export QUIET=false

export ENVIRONMENT_NAME=mkieboom-cicd-env
export CLUSTER_NAME=mkieboom-cicd-gcp
export CLUSTER_CLOUD=gcp
export CLUSTER_REGION=europe-west4

export SCHEMA_REGISTRY_CLOUD=gcp
export SCHEMA_REGISTRY_GEO=eu

export CLIENT_CONFIG=kafka.config

# Deploy the Confluent Cloud stack based on above configuration
ccloud::create_ccloud_stack

# Create a various kafka avro console consumer commands
mkdir ccloud_kafka_examples
cp kafka.config ccloud_kafka_examples/

create_kafka_avro_console_consumer_frombeginning products ccloud_kafka_examples/1_kafka-avro-console-consumer-products.sh
create_kafka_avro_console_consumer_frombeginning customers ccloud_kafka_examples/2_kafka-avro-console-consumer-customers.sh
create_kafka_avro_console_consumer supplies ccloud_kafka_examples/3_kafka-avro-console-consumer-supplies.sh
create_kafka_avro_console_consumer orders ccloud_kafka_examples/4_kafka-avro-console-consumer-orders.sh
create_kafka_avro_console_consumer product_supply_and_demand ccloud_kafka_examples/5_kafka-avro-console-consumer-product_supply_and_demand.sh

# cat <<EOF > ccloud_kafka_examples/1_kafka-avro-console-consumer-products.sh
# kafka-avro-console-consumer \
#   --bootstrap-server ${BOOTSTRAP_SERVERS} \
#   --consumer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
#   --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
#   --from-beginning \
#   --topic products
# EOF
# chmod +x ccloud_kafka_examples/1_kafka-avro-console-consumer-products.sh

# cat <<EOF > ccloud_kafka_examples/2_kafka-avro-console-consumer-customers.sh
# kafka-avro-console-consumer \
#   --bootstrap-server ${BOOTSTRAP_SERVERS} \
#   --consumer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
#   --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
#   --from-beginning \
#   --topic customers
# EOF
# chmod +x ccloud_kafka_examples/2_kafka-avro-console-consumer-customers.sh


# cat <<EOF > ccloud_kafka_examples/3_kafka-avro-console-consumer-supplies.sh
# kafka-avro-console-consumer \
#   --bootstrap-server ${BOOTSTRAP_SERVERS} \
#   --consumer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
#   --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
#   --topic supplies
# EOF
# chmod +x ccloud_kafka_examples/3_kafka-avro-console-consumer-supplies.sh

# cat <<EOF > ccloud_kafka_examples/4_kafka-avro-console-consumer-orders.sh
# kafka-avro-console-consumer \
#   --bootstrap-server ${BOOTSTRAP_SERVERS} \
#   --consumer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
#   --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
#   --topic orders
# EOF
# chmod +x ccloud_kafka_examples/4_kafka-avro-console-consumer-orders.sh


# cat <<EOF > ccloud_kafka_examples/5_kafka-avro-console-consumer-product_supply_and_demand.sh
# kafka-avro-console-consumer \
#   --bootstrap-server ${BOOTSTRAP_SERVERS} \
#   --consumer.config $CLIENT_CONFIG \
#   --property basic.auth.credentials.source=USER_INFO \
#   --property schema.registry.url=${SCHEMA_REGISTRY_ENDPOINT} \
#   --property schema.registry.basic.auth.user.info=`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $1}'`:`echo $SCHEMA_REGISTRY_CREDS | awk -F: '{print $2}'` \
#   --topic product_supply_and_demand
# EOF
# chmod +x ccloud_kafka_examples/5_kafka-avro-console-consumer-product_supply_and_demand.sh


# Create a curl example command to test the ccloud ksqlDB
cat <<EOF > ccloud_kafka_examples/curl-ksqldb-example.sh
curl -sS ${KSQLDB_ENDPOINT} -u `echo $KSQLDB_CREDS | awk -F: '{print $1}'`:`echo $KSQLDB_CREDS | awk -F: '{print $2}'`
EOF
chmod +x ccloud_kafka_examples/curl-ksqldb-example.sh


# Create a env file for cp-all-in-one-cloud
curl -sS https://raw.githubusercontent.com/confluentinc/examples/latest/ccloud/ccloud-generate-cp-configs.sh > ccloud-generate-cp-configs.sh
bash ./ccloud-generate-cp-configs.sh $CLIENT_CONFIG
source ./delta_configs/env.delta


# Run a local instance of Connect with the Datagen source connector
git clone https://github.com/confluentinc/cp-all-in-one
docker-compose -f cp-all-in-one/cp-all-in-one-cloud/docker-compose.yml up -d connect

# Wait for Kafka connect to be ready
echo "Waiting for Kafka Connect to start listening on localhost"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -eq 000 ] ; do 
  #echo -e $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  echo -n "."
  sleep 5 
done

# Copy the datagen files into the connect container
docker cp connect_datagen_avro/datagen_customers.avro connect:/datagen_customers.avro
docker cp connect_datagen_avro/datagen_products.avro connect:/datagen_products.avro
docker cp connect_datagen_avro/datagen_orders.avro connect:/datagen_orders.avro
docker cp connect_datagen_avro/datagen_supplies.avro connect:/datagen_supplies.avro


# Create topics for the datagen sink connector
ccloud kafka topic create customers --partitions 1 --if-not-exists
ccloud kafka topic create products --partitions 1 --if-not-exists
ccloud kafka topic create orders --partitions 1 --if-not-exists
ccloud kafka topic create supplies --partitions 1 --if-not-exists

# # Create topics for the ksqlDB queries
ccloud kafka topic create total_order_value --partitions 1 --if-not-exists
ccloud kafka topic create total_order_value_per_customer --partitions 1 --if-not-exists
ccloud kafka topic create product_supply_and_demand --partitions 1 --if-not-exists
ccloud kafka topic create current_stock --partitions 1 --if-not-exists
ccloud kafka topic create total_order_value_per_customer_last_3mins --partitions 1 --if-not-exists
ccloud kafka topic create product_demand_last_3mins --partitions 1 --if-not-exists


# Allow ksqlDB to create, write, read all topics and consumer groups
export SERVICE_ACCOUNT_ID=$(($SERVICE_ACCOUNT_ID + 1))
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation CREATE --topic '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation WRITE --topic '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation READ --topic '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DESCRIBE --topic '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DESCRIBE_CONFIGS --topic '*'

ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation READ --consumer-group '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation WRITE --consumer-group '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation CREATE --consumer-group '*'

ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation DESCRIBE --transactional-id '*'
ccloud kafka acl create --allow --service-account $SERVICE_ACCOUNT_ID --operation WRITE --transactional-id '*'


# Deploy the datagen connectors
curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_customers",
  "config": {
    "name": "datagen_customers",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "customers",
    "schema.filename": "/datagen_customers.avro",
    "schema.keyfield": "id",
    "max.interval": "20",
    "iterations": "10",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
#docker exec -it connect curl -X GET localhost:8083/connectors/datagen_customers/status | jq .


curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_products",
  "config": {
    "name": "datagen_products",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "products",
    "schema.filename": "/datagen_products.avro",
    "schema.keyfield": "id",
    "max.interval": "20",
    "iterations": "6",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_products/status | jq .


curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_orders",
  "config": {
    "name": "datagen_orders",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "orders",
    "schema.filename": "/datagen_orders.avro",
    "schema.keyfield": "id",
    "max.interval": "5000",
    "iterations": "99999999",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_orders/status | jq .



curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d \
'{
  "name": "datagen_supplies",
  "config": {
    "name": "datagen_supplies",
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "tasks.max": "1",
    "kafka.topic": "supplies",
    "schema.filename": "/datagen_supplies.avro",
    "schema.keyfield": "id",
    "max.interval": "3000",
    "iterations": "99999999",
    "format": "json",
    "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
  }
}'

sleep 1
# docker exec -it connect curl -X GET localhost:8083/connectors/datagen_supplies/status | jq .

# Create a script to launch ksqlDB cli
cat <<EOF > ccloud_kafka_examples/ksqldb-launch.sh
ksql -u `echo $KSQLDB_CREDS | awk -F: '{print $1}'` -p `echo $KSQLDB_CREDS | awk -F: '{print $2}'` ${KSQLDB_ENDPOINT}
EOF
chmod +x ccloud_kafka_examples/ksqldb-launch.sh


# Create a script to run the ksqlDB queries
cat <<EOFSH > ccloud_kafka_examples/ksqldb-run-queries.sh
ksql -u `echo $KSQLDB_CREDS | awk -F: '{print $1}'` -p `echo $KSQLDB_CREDS | awk -F: '{print $2}'` ${KSQLDB_ENDPOINT} <<EOF
RUN SCRIPT '../ksqlqueries.sql';
exit
EOF
EOFSH
chmod +x ccloud_kafka_examples/ksqldb-run-queries.sh

# Create a script to test if ksql is up and running and available
cat <<EOF > ccloud_kafka_examples/ksqldb-available-test.sh
export KSQLDB_CREDENTIALS=`echo $KSQLDB_CREDS | awk -F: '{print $1}'`:`echo $KSQLDB_CREDS | awk -F: '{print $2}'`
while [ $(curl -s -o /dev/null -w %{http_code} ${KSQLDB_ENDPOINT} -u ${KSQLDB_CREDENTIALS}) -eq 000 ]
do 
  echo -n "."
  sleep 5
done
EOF
chmod +x ccloud_kafka_examples/ksqldb-available-test.sh

# Wait for ksqlDB Server to be ready
echo -e "\n\nWaiting for KSQL to be available before launching CLI\n"
export KSQLDB_CREDENTIALS=`echo $KSQLDB_CREDS | awk -F: '{print $1}'`:`echo $KSQLDB_CREDS | awk -F: '{print $2}'`
while [ $(curl -s -o /dev/null -w %{http_code} ${KSQLDB_ENDPOINT} -u ${KSQLDB_CREDENTIALS}) -eq 000 ]
do 
  echo -n "."
  sleep 5
done

# ksqlDB is available, run the sql queries file
bash ccloud_kafka_examples/ksqldb-run-queries.sh

cd ccloud_kafka_examples
echo "Deployment completed. Use the scripts in this folder to consume data from the topics and query ksqlDB."


