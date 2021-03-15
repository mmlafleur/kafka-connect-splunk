FROM confluentinc/cp-kafka-connect-base:6.1.0-1-ubi8

COPY docker/init.sh /docker/init.sh
COPY docker/env.template /docker/env.template
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /docker/entrypoint.sh /docker/init.sh && \
    confluent-hub install --no-prompt splunk/kafka-connect-splunk:2.0

EXPOSE 8083

ENTRYPOINT /docker/entrypoint.sh
#CMD /scripts/init.sh