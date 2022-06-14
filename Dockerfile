
FROM apache/nifi

ENV NIFI_BASE_DIR=/opt/nifi
ENV NIFI_HOME ${NIFI_BASE_DIR}/nifi-current
ENV NIFI_TOOLKIT_HOME ${NIFI_BASE_DIR}/nifi-toolkit-current

ARG SINGLE_USER_CREDENTIALS_USERNAME
ARG SINGLE_USER_CREDENTIALS_PASSWORD
ARG NIFI_WEB_HTTPS_PORT

ARG ACCESS_KEY
ARG SECRET_KEY
ARG BUCKET_NAME
ARG S3_REGION
ARG S3_URL

ENV BUCKET_NAME=${BUCKET_NAME}

ENV SINGLE_USER_CREDENTIALS_USERNAME=${SINGLE_USER_CREDENTIALS_USERNAME}
ENV SINGLE_USER_CREDENTIALS_PASSWORD=${SINGLE_USER_CREDENTIALS_PASSWORD}

ENV NIFI_WEB_HTTPS_PORT=${NIFI_WEB_HTTPS_PORT}


### Installing s3fs-fuse
USER root

RUN apt update && apt upgrade -y
RUN apt -y install automake nano autotools-dev gettext-base fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git

RUN cd s3fs-fuse && sed -i 's/MAX_MULTIPART_CNT         = 10 /MAX_MULTIPART_CNT         = 1 /' src/fdcache_entity.cpp
RUN cd s3fs-fuse && ./autogen.sh && ./configure && make && make install

RUN cp s3fs-fuse/src/s3fs /usr/local/bin/s3fs

RUN rm -rf s3fs-fuse

RUN echo "user_allow_other" >> /etc/fuse.conf

COPY run_nifi.sh run_nifi.sh
RUN chown nifi run_nifi.sh
RUN chmod +x run_nifi.sh

USER nifi

RUN mkdir -p ${NIFI_HOME}/script
RUN chown nifi ${NIFI_HOME}/script

WORKDIR ${NIFI_HOME}


ENTRYPOINT ["../scripts/run_nifi.sh"]