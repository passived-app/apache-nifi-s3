# apache-nifi-s3
This is a fork of the apache/nifi container with an integrated s3 directory at the nifi root path. This docker can be used inside a kubernetes to access files for the apache nifi.

# Why

At passived.app we use the apache/nifi framework to update all our informations about the defi-apps and chains. 
Therefore we use a python script and multiple Connectors to check/update different attributes of the projects.

![](passived.jpg)

## Use with kubernetes

apache-nifi-s3.yaml:

```
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nifi
  namespace: default
spec:
  selector:
    matchLabels:
      app: nifi
  template:
    metadata:
      labels:
        app: nifi
    spec:
      containers:
        - securityContext:
            privileged: true
        - name: nifi
          image: passivedapp/apache-nifi-s3
          ports:
            - name: https
              containerPort: 8443
          env:
            - name: SINGLE_USER_CREDENTIALS_USERNAME
              value: admin
            - name: SINGLE_USER_CREDENTIALS_PASSWORD
              value: "<default-password-for-admin>"
            - name: NIFI_WEB_HTTPS_PORT
              value: '8443'
            - name: ACCESS_KEY
              value: "<bucket-access-key>"
            - name: SECRET_KEY
              value: "<bucket-secret-key>"
            - name: BUCKET_NAME
              value: "<your-bucket-name>"
            - name: S3_URL
              value: https://s3.fr-par.scw.cloud
            - name: S3_REGION
              value: fr-par


```


## Use with docker

```

docker run -d \
    -e SINGLE_USER_CREDENTIALS_USERNAME=admin \
    -e SINGLE_USER_CREDENTIALS_PASSWORD=<default-password-for-admin> \
    -e NIFI_WEB_HTTPS_PORT=8443 \
    -e ACCESS_KEY=<bucket-access-key> \
    -e SECRET_KEY=<bucket-secret-key> \
    -e BUCKET_NAME=<your-bucket-name> \
    -e S3_URL=https://s3.fr-par.scw.cloud \
    -e S3_REGION=fr-par \
    --name apache-nifi-s3 \
     passivedapp/apache-nifi-s3 

```
 
## Parameters

| Parameter    | Description                                          |
|--------------|------------------------------------------------------|
| `SINGLE_USER_CREDENTIALS_USERNAME` | The username for the apache/nifi                     |
| `SINGLE_USER_CREDENTIALS_PASSWORD`   | The password for the apache/nifi instance            |
| `NIFI_WEB_HTTPS_PORT`   | The port of the apache/nifi project. (default: 8443) |
| `ACCESS_KEY`   | Bucket Access Key                                    |
| `SECRET_KEY`   | Bucket Secret Key                                    |
| `BUCKET_NAME`   | Bucket Name                                          |
| `S3_URL`   | S3 URL of your Bucket Cloud Provider                 |
| `S3_REGION`   | S3 Region of your Bucket Cloud Provider              |
| `SPECIAL_PARAMS` | You can send any params to the s3fs command |


## S3 Bucket Urls for different Cloud Provider

If you are using other S3 provider than AWS here are some example Urls:

### Scaleway
Region Example: fr-par \
https:// s3.&lt;REGION&gt;.scw.cloud

### AWS
Region Example: us-west-2 \
https:// s3.&lt;REGION&gt;.amazonaws.com

