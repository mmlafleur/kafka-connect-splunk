#!/bin/bash

echo "@@@ Initializing a data collection task with Splunk...\n Sleeping for 60 seconds..."

sleep 60

source /scripts/env

## External file example:
curl -o response.log -X POST -H "Content-Type: application/json" http://localhost:8083/connectors \
  -d '{
    "name": "${KAFKA_NAME}",
    "config": {
      "connector.class": "${CONNECTOR_CLASS}",
      "tasks.max": "${TASKS_MAX}",
      "topics":"${TOPICS}",
      "splunk.indexes": "${SPLUNK_INDEXES}",
      "splunk.hec.uri": "${SPLUNK_HEC_URI}",
      "splunk.hec.token": "${SPLUNK_HEC_TOKEN}",
      "splunk.hec.raw": "${SPLUNK_HEC_RAW}",
      "splunk.hec.total.channels": "${SPLUNK_HEC_TOTAL_CHANNELS}",
      "splunk.hec.ack.enabled":"${SPLUNK_HEC_ACK_ENABLED}",
      "splunk.hec.ssl.validate.certs":"${SPLUNK_HEC_SSL_VALIDATE_CERTS}"
    }
}'
