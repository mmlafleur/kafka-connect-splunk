#!/bin/bash

grep -v ^# /docker/env > /docker/env.clear
while read line; do
  export "$line" || :
done < /docker/env.clear

printenv

/etc/confluent/docker/run &
echo "@@@ Waiting for Kafka Connect to start listening on kafka-connect-splunk ⏳"

while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -eq 000 ] ; do
  echo -e $(date) "@@@ Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  sleep 5
done

echo -e "\n--\n+> @@@ Creating Kafka Connect Splunk Sink"

echo "@@@ Initializing a data collection task with Splunk...\n Sleeping for 60 seconds..."

sleep 60

## External file example:
curl -o response.log -X POST -H "Content-Type: application/json" http://localhost:8083/connectors -d @- <<EOF
  {
    "name":"$HOSTNAME",
    "config": {
      "connector.class":"$CONNECTOR_CLASS",
      "tasks.max":"$TASKS_MAX",
      "topics":"$TOPICS",
      "splunk.indexes":"$SPLUNK_INDEXES",
      "splunk.hec.uri":"$SPLUNK_HEC_URI",
      "splunk.hec.token":"$SPLUNK_HEC_TOKEN",
      "splunk.hec.raw":"$SPLUNK_HEC_RAW",
      "splunk.hec.total.channels":"$SPLUNK_HEC_TOTAL_CHANNELS",
      "splunk.hec.ack.enabled":"$SPLUNK_HEC_ACK_ENABLED",
      "splunk.hec.ssl.validate.certs":"$SPLUNK_HEC_SSL_VALIDATE_CERTS",
      "truncate":500000
    }
  }
EOF

sleep infinity
