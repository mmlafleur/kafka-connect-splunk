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

echo "ENVIRONMENT: $ENVIRONMENT"

# Production role change
if [ "$ENV" == "production" ]; then
    echo "Replacing AWS Credentials role with the production one..."
    sed -i 's#arn:aws:iam::154821788882:role/EC2-ParamStore#arn:aws:iam::154821788882:role/mmlf-production20210712104121157000000009#' /srv/.aws/credentials
fi

echo -e "Fetching parameters from AWS SSM Parameter Store for Environment: [$ENV]..."
aws ssm get-parameters-by-path --output text --with-decryption --recursive --path /${ENV}/app/global | sed "s#/app/global##g" | awk '{print $5,$7}' > $TMPFL
aws ssm get-parameters-by-path --output text --with-decryption --recursive --path /${ENV}/app/${APP_NAME} | sed "s#/app/${APP_NAME}##g" | awk '{print $5,$7}' >> $TMPFL

for TEMPLATE in $(ls /docker/*.template); do
    FILE="$(echo $TEMPLATE | sed "s#.template##g")"
    cp -f $TEMPLATE $FILE
    echo "Generating $FILE"
    while read line; do
        larray=( $line )
        if [[  ${larray[1]} == *"#"*  ]]; then
	        PARAM="$(echo ${larray[0]^^} | tr "/" "_" | sed "s#_${ENV^^}_##g" )"
	        sed -i "s%{{${PARAM}}}%${larray[1]}%g" $FILE 2>/dev/null || sed -i "s|{{${PARAM}}}|${larray[1]}|g" $FILE
	    else
	        PARAM="$(echo ${larray[0]^^} | tr "/" "_" | sed "s#_${ENV^^}_##g" )"
	        sed -i "s#{{${PARAM}}}#${larray[1]}#g" $FILE 2>/dev/null || sed -i "s|{{${PARAM}}}|${larray[1]}|g" $FILE
	    fi
    done < $TMPFL

    # Print all genereted files if env is not production
    [ "$ENV" != "production" ] && cat $FILE
done

rm $TMPFL

# Replace configs with the generated files
cp -f /docker/env.template /home/appuser/.env
#export $(xargs <file)

# Liveliness probe
touch /tmp/healthy

# Start the app
bash /docker/init.sh
