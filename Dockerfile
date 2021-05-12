FROM confluentinc/cp-kafka-connect-base:6.1.0-1-ubi8

USER root
COPY docker/init.sh /docker/init.sh
COPY docker/env.template /docker/env.template
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh /docker/init.sh
COPY docker/aws/credentials /home/appuser/.aws/
ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip /awscliv2.zip
RUN yum -y install unzip && cd / && unzip /awscliv2.zip && ./aws/install
RUN touch /home/appuser/.env && \
    chown -R appuser /home/appuser/.aws /docker && \
    mkdir -p /scripts && \
    ln -s /home/appuser/.env /scripts/env && \
    ln -s /usr/bin/more /usr/bin/less

USER appuser

RUN confluent-hub install --no-prompt splunk/kafka-connect-splunk:2.0
RUN source /docker/env.template

EXPOSE 8083

ENTRYPOINT ["bash", "/entrypoint.sh"]
