#!/bin/sh -e

echo $ACCESS_KEY:$SECRET_KEY > /home/nifi/.passwd-s3fs
chmod 600 /home/nifi/.passwd-s3fs

s3fs $BUCKET_NAME $NIFI_HOME/script -o allow_other -o passwd_file=/home/nifi/.passwd-s3fs -o use_path_request_style -o endpoint=$S3_REGION -o parallel_count=15 -o multipart_size=128 -o nocopyapi -o url=$S3_URL

sh start.sh
