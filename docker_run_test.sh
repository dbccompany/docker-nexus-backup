# Build:
docker build -t nexus-backup:test .

# Run:

docker run -it --rm     \
        --mount type=bind,source=$(pwd)/rclone_config/rclone.conf,target=/root/.config/rclone/rclone.conf,readonly \
        -v nexus-data:"/nexus-data" \
        -e NEXUS_AUTHORIZATION="Basic YWRtaW46YWRtaW4=" \
        -e NEXUS_BACKUP_DIRECTORY="/nexus-data/backup" \
        -e NEXUS_DATA_DIRECTORY="/nexus-data" \
        -e NEXUS_LOCAL_HOST_PORT="172.17.0.2:8081" \
        -e TARGET_BUCKET="NexusBackupTest" \
        -e GRACE_PERIOD="60" \
        -v nexus-data:"/nexus-data" \
        -e CLOUD_IAM_SERVICE_ACCOUNT_KEY_PATH="/tmp" \
        nexus-backup:test #sh /docker-entrypoint.sh

# Cleanup:
docker rmi nexus-backup:test
docker image prune
