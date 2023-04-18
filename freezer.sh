#!/bin/sh
: '

FREEZER.SH
Stops and captures the current state of docker containers.
Compressing the current state.

'
# <Log-Rollover>
ROLLOVER_INT=14
#
# <VARS>
DATE="$(date +"%Y-%m-%d")"
CONT_DIR="/disks/compute/docker"
BACKUP_DIR="/disks/raid/backup/docker"
STARTUP=$SECONDS
#
# <RUN>
#
# Initial Log
LOGHEADER="[TH] [Freezer.sh]"
logger "$LOGHEADER Start-up"
#
# Create backup dir if does not exist
mkdir -p "$BACKUP_DIR"
#
# Record currently running containers
CURRENT_CONTAINERS="$(docker ps -q)"
#
# Stop all containers
logger "$LOGHEADER Stoping Containers"
docker stop ${CURRENT_CONTAINERS}
#
# Capture and compress the containers
logger "$LOGHEADER Starting Compression"
tar -cfz "$BACKUP_DIR/$DATE-docker.tar.gz" "$CONT_DIR/."
logger "$LOGHEADER Finished Compression"
#
# Restart the containers
logger "$LOGHEADER Starting Containers"
docker start ${CURRENT_CONTAINERS}
#
# Roll over logs
find "$BACKUP_DIR/." -mtime "+$ROLLOVER_INT" -delete
logger "$LOGHEADER Removing backups older than ($ROLLOVER_INT) days"
#
logger "$LOGHEADER Finished. Completed in ($(( $SECONDS - $STARTUP )))s"
