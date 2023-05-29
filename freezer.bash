#!/bin/bash
: '

FREEZER.SH
Stops and captures the current state of docker containers.
Compressing the current state.

'
#
# <CONSTANTS>
LOGHEADER="[TH][Freezer.sh]"
DATE="$(date +"%Y-%m-%dT%H:%M")"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
#
# Log Func
log() {
    MSG="$LOGHEADER $1"
    echo "$MSG"; logger "$MSG"
}
# Fail Check Function
fc() {
    if [[ -n $1 ]]; then log "$2 ErrorMsg($1)"; exit 1; fi
}
# Empty Check Function
ec() {
    if [[ -z $1 ]]; then log "$2"; exit 1; fi
}
#
#
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Source Path (Rq)
    "-s" | "--source")
        SOURCE=${ARGS[$ARGC+1]}
    ;;
    # Target Path for Tar (Rq)
    "-t" | "--target")
        TARGET=${ARGS[$ARGC+1]}
    ;;
    # Set rollover interval (Opt)
    "-r" | "--rollover")
        ROLLOVER=${ARGS[$ARGC+1]}
    ;;
    # Use Pigz instead of gzip (Opt)
    "--pigz")
        PIGZ=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Freezer Help Menu
    -s --source    Path to container data
    -t --target    Target directory for tar backup
    -r --rollover  Sets rollover interval. Defaults to 14 days.
       --pigz      Uses pigz for compression instead of gzip
    -h --help      This menu\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
# Validate required inputs (Fatals)
ec "$SOURCE" "[0x1] No Source directory provided. Please use -h or --help to see required arguments."
ec "$TARGET" "[0x1] No Target directory provided. Please use -h or --help to see required arguments."
if [[ -z $ROLLOVER ]]; then log "No Rollover integer provided, defaulting to 14 days."; ROLLOVER=14; fi
# Fix for bug when source is '.'
if [[ "$SOURCE" == "." ]]; then SOURCE=$(pwd); fi
#
#
# <MAIN>
#
# Initial Log
log "Start-up"
#
# Create backup dir if does not exist
fc "$(mkdir -p "$TARGET" 2>&1)" "[0x1] Failed to Create/Access target directory '$TARGET'"
#
# Record currently running containers
CURRENT_CONTAINERS="$(docker ps -q)"
#
# Stop all containers
log "Stoping Containers"
docker stop ${CURRENT_CONTAINERS}
#
# Capture and compress the containers
log "Starting Compression $( if [[ $PIGZ ]]; then echo "using pigz"; fi )"
#
if [[ $PIGZ ]]; then
    fc "$(tar -c --use-compress-program=pigz -f "$TARGET/$DATE-docker.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Compression with Pigz Failed!"
else
    fc "$(tar -zcf "$TARGET/$DATE-docker.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Compression Failed!"
fi
log "Finished Compression"
#
# Restart the containers
log "Starting Containers"
docker start ${CURRENT_CONTAINERS}
#
# Roll over logs
find "$TARGET/." -mtime "+$ROLLOVER" -delete
log "Removing backups older than ($ROLLOVER) days"
#
log "Finished. Completed in ($(( $SECONDS - $STARTUP )))s"
