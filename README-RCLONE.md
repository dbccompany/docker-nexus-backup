# RCLONE docker backup usage

## 1- Build the docker image

```bash
TAG='docker-nexus-backup:latest'
docker build -t $TAG .
```

## 2 Run the docker image

```bash
TAG='docker-nexus-backup:latest'
docker run -it --rm --name docker-nexus-backup-rclone     \
        --mount type=bind,source=$(pwd)/rclone_config/rclone.conf,target=/root/.config/rclone/rclone.conf,readonly \
        -v nexus-data:"/nexus-data" \
        -e NEXUS_AUTHORIZATION="Basic YWRtaW46YWRtaW4=" \
        -e NEXUS_BACKUP_DIRECTORY="/nexus-data/backup" \
        -e NEXUS_DATA_DIRECTORY="/nexus-data" \
        -e NEXUS_LOCAL_HOST_PORT="172.17.0.2:8081" \
        -e TARGET_BUCKET="nexus-backup-test" \
        -e OFFLINE_REPOS="myrepo" \
        -e RCLONE_REMOTE="minio-local"  \
        $TAG
```

## 2-a Requirements

- Configure one or many Rclone remotes in a configuration file (example under `rclone_config/rclone.conf`)
- Mount the RCLONE configuration file to `/root/.config/rclone/rclone.conf` (use configmap for k8s)
- Mount the Nexus data directory : `/nexus-data`
- Mount the Nexus data backup directory
- Configure the nexus host, port and authorization token
- Authorization token is : `"login:password".getBytes().encodeBase64().toString()`
- TARGET_BUCKET : target S3 bucket
- OFFLINE_REPOS : repositories that will be put offline before the backup starts, requires enabling script execution on the nexus server
- RCLONE_REMOTE : rclone remote to use (defined in the rlcone configuration file)

## 2-b Optional

Put the repositories defined in '\$OFFLINE_REPOS' offline before updating, requires enabling script execution on Nexus

Add `nexus.scripts.allowCreation=true` to file: `$data-dir/etc/nexus.properties` then restart the nexus server.

## 3 Trigger the build

Run the command `touch ${NEXUS_BACKUP_DIRECTORY}/${TRIGGER_FILE_NAME}` the default TRIGGER_FILE_NAME value is `.backup`

```bash
docker exec -it docker-nexus-backup-rclone bash
touch ${NEXUS_BACKUP_DIRECTORY}/.backup
```
