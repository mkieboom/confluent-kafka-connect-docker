SET 'auto.offset.reset' = 'earliest';

SET 'commit.interval.ms'='2000';

CREATE TABLE customers (id INT PRIMARY KEY, name VARCHAR)
  WITH (kafka_topic='customers', value_format='avro');

CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR, price INT)
  WITH (kafka_topic='products', value_format='avro');

CREATE STREAM orders (id INT KEY, customerid INT, productid INT, quantity INT)
  WITH (KAFKA_TOPIC='orders', VALUE_FORMAT='avro');


CREATE STREAM supplies (id INT KEY, supplierid INT, productid INT, quantity INT)
  WITH (KAFKA_TOPIC='supplies', VALUE_FORMAT='avro');

CREATE STREAM product_supply_and_demand (id INT KEY, productid INT, quantity INT)
  WITH (KAFKA_TOPIC='product_supply_and_demand', VALUE_FORMAT='avro');

INSERT INTO product_supply_and_demand
  SELECT id, productid, quantity FROM supplies;

INSERT INTO product_supply_and_demand
  SELECT id, productid, quantity * -1 as quantity FROM orders;


CREATE TABLE current_stock WITH (KAFKA_TOPIC = 'current_stock', value_format='avro')
  AS SELECT productid, SUM(quantity) as stock_level
  FROM product_supply_and_demand GROUP BY productid;

CREATE TABLE product_demand_last_3mins WITH (PARTITIONS = 1, KAFKA_TOPIC = 'product_demand_last_3mins')
  AS SELECT timestamptostring(WINDOWSTART,'HH:mm:ss') "WINDOW_START_TIME",
            timestamptostring(WINDOWEND,'HH:mm:ss') "WINDOW_END_TIME",
            productid,
            SUM(quantity) "DEMAND_LAST_3MINS"
  FROM orders WINDOW HOPPING (SIZE 3 MINUTES, ADVANCE BY 1 MINUTE)
  GROUP BY productid EMIT CHANGES;
