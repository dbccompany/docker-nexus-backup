## Build Rclone
FROM golang AS rclone_builder

COPY ./rclone /go/src/github.com/rclone/rclone/
WORKDIR /go/src/github.com/rclone/rclone/

RUN make quicktest
RUN \
  CGO_ENABLED=0 \
  make
RUN ./rclone version

## Build final image
FROM alpine:3.10

LABEL maintainer devops@travelaudience.com

# The authorization header to use when calling the Nexus API.
ENV NEXUS_AUTHORIZATION "Basic YWRtaW46YWRtaW4xMjMK"

# The directory to which the Nexus 'backup-2' task will produce its output.
ENV NEXUS_BACKUP_DIRECTORY="/nexus-data/backup"

# The Nexus data directory.
ENV NEXUS_DATA_DIRECTORY="/nexus-data"

# The pod-local host and port at which Nexus can be reached.
ENV NEXUS_LOCAL_HOST_PORT "localhost:8081"

# The names of the repositories we need to take down to achieve a consistent backup.
ENV OFFLINE_REPOS "maven-central maven-public maven-releases maven-snapshots"

# The name of the bucket to which the resulting backups will be uploaded.
ENV TARGET_BUCKET "nexus-backup"

# The amount of time in seconds to wait between stopping repositories and starting the upload.
ENV GRACE_PERIOD "60"

# The name of the Rclone remote.
ENV RCLONE_REMOTE "aws1"

WORKDIR /tmp

RUN apk add --no-cache --update ca-certificates bash curl inotify-tools openssl fuse

COPY --from=rclone_builder /go/src/github.com/rclone/rclone/rclone /usr/local/bin/

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD /scripts/start-repository.groovy /scripts/start-repository.groovy
ADD /scripts/stop-repository.groovy /scripts/stop-repository.groovy

ENTRYPOINT ["/docker-entrypoint.sh"]
