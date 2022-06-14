
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
ARG S3_REGION=fr-par
ARG S3_URL=https://s3.fr-par.scw.cloud

ENV SINGLE_USER_CREDENTIALS_USERNAME=${SINGLE_USER_CREDENTIALS_USERNAME}
ENV SINGLE_USER_CREDENTIALS_PASSWORD=${SINGLE_USER_CREDENTIALS_PASSWORD}

ENV NIFI_WEB_HTTPS_PORT=${NIFI_WEB_HTTPS_PORT}


### Installing s3fs-fuse
USER root

RUN apt update && apt upgrade -y
RUN apt -y install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git

RUN cd s3fs-fuse && sed -i 's/MAX_MULTIPART_CNT         = 10 /MAX_MULTIPART_CNT         = 1 /' src/fdcache_entity.cpp
RUN cd s3fs-fuse && ./autogen.sh && ./configure && make && make install

RUN cp s3fs-fuse/src/s3fs /usr/local/bin/s3fs

RUN echo ${ACCESS_KEY}:${SECRET_KEY} > $HOME/.passwd-s3fs
RUN chmod 600 $HOME/.passwd-s3fs

RUN mkdir -p ${NIFI_HOME}/script

RUN if ! grep -q 'init-s3fs' /etc/fstab ; then \
      echo '# init-s3fs' >> /etc/fstab ; \
      echo 's3fs ${BUCKET_NAME} ${NIFI_HOME}/script -o allow_other -o passwd_file=$HOME/.passwd-s3fs -o use_path_request_style -o endpoint=${S3_REGION} -o parallel_count=15 -o multipart_size=128 -o nocopyapi -o url=${S3_URL}' >> /etc/fstab ; \
    fi

USER nifi

WORKDIR ${NIFI_HOME}

ENTRYPOINT ["../scripts/start.sh"]