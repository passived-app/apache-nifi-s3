
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


RUN echo ${ACCESS_KEY}:${SECRET_KEY} > /root/.passwd-s3fs
RUN chmod 600 /root/.passwd-s3fs

RUN mkdir -p ${NIFI_HOME}/script
RUN chown nifi ${NIFI_HOME}/script

RUN if ! grep -q 'init-s3fs' /etc/fstab ; then \
      echo '# init-s3fs' >> /etc/fstab ; \
      echo s3fs#${BUCKET_NAME} ${NIFI_HOME}/script fuse _netdev,passwd_file=/root/.passwd-s3fs,allow_other,use_path_request_style,endpoint=${S3_REGION},url=${S3_URL} 0 0 > fstab.source ; \
    fi

USER nifi

WORKDIR ${NIFI_HOME}

ENTRYPOINT ["../scripts/start.sh"]