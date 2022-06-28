#!/bin/sh -e

echo $ACCESS_KEY:$SECRET_KEY > /home/nifi/.passwd-s3fs
chmod 600 /home/nifi/.passwd-s3fs

if [[ -z "${S3_REGION}" ]]; then
  s3fs $BUCKET_NAME $NIFI_HOME/script -o allow_other -o passwd_file=/home/nifi/.passwd-s3fs $SPECIAL_PARAMS -o url=$S3_URL
else
  s3fs $BUCKET_NAME $NIFI_HOME/script -o allow_other -o passwd_file=/home/nifi/.passwd-s3fs -o endpoint=$S3_REGION $SPECIAL_PARAMS -o url=$S3_URL
fi

sh ../scripts/start.sh
