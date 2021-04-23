#!/bin/sh

APP_NAME="kafka-connect-splunk"
TMPFL="/tmp/.tmpfl"

if [ -z ${ENVIRONMENT} ]; then
  ENVIRONMENT=$1
fi

case $ENVIRONMENT in
    test|tests) ENV=tests;;
	localdev|dev|development) ENV=dev;;
	main|master|production|prod|parent) ENV=production;;
	*) ENV=staging;;
esac

echo -e "Env: $ENV"

# Production role change
if [ "$ENV" == "production" ]; then
    echo "Replace AWS Credentials role with production one..."
    sed -i 's#arn:aws:iam::593202966396:role/mmlf-staging-eks-eks-node-role#arn:aws:iam::593202966396:role/production-eks-NodeInstanceRole-PF0E41JLO9OV#' /home/appuser/.aws/credentials
fi

echo -e "Fetching parameters from AWS SSM Parameter Store for Environment: [$ENV]..."
aws ssm get-parameters-by-path --output text --with-decryption --recursive --path /${ENV}/app/global | sed "s#/app/global##g" | awk '{print $4,$6}' > $TMPFL
aws ssm get-parameters-by-path --output text --with-decryption --recursive --path /${ENV}/app/${APP_NAME} | sed "s#/app/${APP_NAME}##g" | awk '{print $4,$6}' >> $TMPFL

for TEMPLATE in $(ls docker/*.template); do
    FILE="$(echo $TEMPLATE | sed "s#.template##g")"
    cp -f $TEMPLATE $FILE
    echo "Generating $FILE"
    while read line; do
        larray=( $line )
        PARAM="$(echo ${larray[0]^^} | tr "/" "_" | sed "s#_${ENV^^}_##g" )"
        sed -i "s#{{${PARAM}}}#${larray[1]}#g" $FILE 2>/dev/null || sed -i "s|{{${PARAM}}}|${larray[1]}|g" $FILE
    done < $TMPFL
done

rm $TMPFL

# Replace configs with the generated files
cp -f /docker/env.template /home/appuser/.env
#export $(xargs <file)

# Start the app
bash /docker/init.sh
