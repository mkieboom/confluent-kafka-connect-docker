
### Use-case
Capturing data using Kafka Connect JDBC source connector from a Postgres database. Events will be pushed into a compacted topic to demonstrate that database updates will result in new events while deleting previous events from the topic.

Detailed blog on using the JDBC source connector:
https://www.confluent.io/blog/kafka-connect-deep-dive-jdbc-source-connector/

### Clone the project
```
git clone https://github.com/mkieboom/confluent-kafka-connect-docker
cd jdbc
```

### Launch the environment using docker-compose
```
docker-compose up -d
docker-compose ps
```

### Load data into the Postgres database container
```
cat ./customers.sql | docker exec -i postgres psql -U postgres -d postgres
```

### Create a compacted topic as the target topic for the JDBC source connector
```
docker exec -it broker kafka-topics --bootstrap-server localhost:9092 --topic postgrescustomers --create --replication-factor 1 --partitions 1 --config "cleanup.policy=compact" --config "delete.retention.ms=100"  --config "segment.ms=100" --config "min.cleanable.dirty.ratio=0.01"
```

### Check if the JDBC source connector is deployed correctly and available
```
curl -sS localhost:8083/connector-plugins | jq -c '.[] | select( .class | contains("Jdbc") )'
```

### Deploy the JDBC source connector
```
docker exec connect \
     curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
               "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
                    "name": "postgres-source",
                    "tasks.max": "1",
                    "connection.url": "jdbc:postgresql://postgres/postgres?user=postgres&password=postgres&ssl=false",
                    "table.whitelist": "customers",
                    "mode": "timestamp+incrementing",
                    "timestamp.column.name": "update_ts",
                    "incrementing.column.name": "id",
                    "validate.non.null":"false",
                    "errors.log.enable": "true",
                    "topic.prefix": "postgres",
                    "transforms":"createKey,extractInt",
                    "transforms.createKey.type":"org.apache.kafka.connect.transforms.ValueToKey",
                    "transforms.createKey.fields":"id",
                    "transforms.extractInt.type":"org.apache.kafka.connect.transforms.ExtractField$Key",
                    "transforms.extractInt.field":"id",
                    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
                    "errors.log.include.messages": "true"
          }' \
     http://localhost:8083/connectors/postgres-source/config | jq .
```

### List te running connector and related tasks to check if the status is RUNNING
```
docker exec -it connect curl -X GET localhost:8083/connectors/postgres-source/status | jq .

# When the status is not RUNNING, check the connect logs
docker logs -f connect
```

### Read the database events from the topic to check if the source connector is picking it up correctly
```
docker exec -it schema-registry kafka-avro-console-consumer --bootstrap-server broker:9092 --topic postgrescustomers --from-beginning
```

### Run various update queries on the postgres database to see the topic being compacted
```
# Note: compaction takes some time to happen 
docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User1 Comment2' where id = 1;"
docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User1 Comment3' where id = 1;"
docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User1 Comment4' where id = 1;"

docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User2 Comment2' where id = 2;"
docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User2 Comment3' where id = 2;"
docker exec postgres psql -U postgres -d postgres -c "update customers set comments = 'User2 Comment4' where id = 2;"
```

### Read the events again and notice the earliest records with id 1 and 2 have been deleted due to topic compaction
```
docker exec -it schema-registry kafka-avro-console-consumer --bootstrap-server broker:9092 --topic postgrescustomers --from-beginning
```

### Cleanup
```
docker exec -it connect curl -X DELETE http://localhost:8083/connectors/postgres-source
docker exec -it broker kafka-topics --bootstrap-server broker:9092 --topic postgrescustomers --delete

docker-compose down
docker volume prune -f
```

