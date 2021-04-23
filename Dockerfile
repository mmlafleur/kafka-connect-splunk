FROM confluentinc/cp-kafka-connect-base:6.1.0-1-ubi8

USER root
COPY docker/init.sh /docker/init.sh
COPY docker/env.template /docker/env.template
COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/aws/credentials /home/appuser/.aws/
ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip /awscliv2.zip
RUN cd / && unzip /awscliv2.zip && ./aws/install
RUN chown appuser

USER appuser
#RUN chmod +x /entrypoint.sh /docker/init.sh && \
RUN confluent-hub install --no-prompt splunk/kafka-connect-splunk:2.0

EXPOSE 8083

ENTRYPOINT ["bash", "/entrypoint.sh"]
#CMD /scripts/init.sh