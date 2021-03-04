#!/bin/bash

echo "@@@ Initializing a data collection task with Splunk...\n Sleeping for 60 seconds..."

sleep 60

## External file example:
curl -o response.log -X POST -H "Content-Type: application/json" http://localhost:8083/connectors \
  -d '{
    "name": "kafka-connect-splunk",
    "config": {
      "connector.class": "com.splunk.kafka.connect.SplunkSinkConnector",
      "tasks.max": "3",
      "topics":"products,customers,orders",
      "splunk.indexes": "sandbox_kafka",
      "splunk.hec.uri": "https://http-inputs-mmlafleur.splunkcloud.com:443",
      "splunk.hec.token": "6492f5aa-77ac-4b42-bb9e-380fcdd60b3d",
      "splunk.hec.raw": "true",
      "splunk.hec.total.channels": "1",
      "splunk.hec.ack.enabled":"false",
      "splunk.hec.ssl.validate.certs":"false"
    }
}'
