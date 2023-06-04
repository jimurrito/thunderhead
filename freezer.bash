#!/bin/bash
: '

FREEZER
Stops and captures the current state of docker containers and KVM VMs.
Compressing and Archiving the current state.

'
#
# <CONSTANTS>
LOGHEADER="[TH][Freezer]"
DATE="$(date +"%Y-%m-%d")"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
#
# Log Func
log() {
    echo "$1"; logger "$LOGHEADER $1"
}
# Fail Check Function
fc() {
    if [[ -n $1 ]]; then log "$2 ErrorMsg($1)"; exit 1; fi
}
# Fail Check - NO KILL - Function
fcnk() {
    if [[ -n $1 ]]; then log "$2 ErrorMsg($1)"; fi
}
# Empty Check Function
ec() {
    if [[ -z $1 ]]; then log "$2"; exit 1; fi
}
# Run scripts BULK
runbulk() {
    for i in $( ls "$1"*.sh | grep -v DEP ); do
        log "Recreating '$i'..."
        bash "$i"
    done
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
    # Restart containers on backup
    "-R" | "--reset")
        RESET=true
    ;;
    # Custom run scripts (Hard restart)
    "-H" | "--hardreset")
        HARD=${ARGS[$ARGC+1]}
    ;;
    # Use Pigz instead of gzip (Opt)
    "--pigz")
        PIGZ=true
    ;;
    # KVM instead of Docker
    "-k" | "--kvm")
        KVM=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Freezer Help Menu
    -s --source     Path to container data
    -t --target     Target directory for tar backup
    -r --rollover   Sets rollover interval. Defaults to 14 days.
    -R --reset      Restart docker containers during the backup
    -H --hardreset  Instead of using the standard docker pause method, all containers are destroyed and recreated. 
                        Requires custom runscripts. (See github)
       --pigz       Uses pigz for compression instead of gzip
    -k --kvm        Backs up KVM VMs instead of Docker containers. Hardreset not support.
    -h --help       This menu\n"
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
# Compress Function
compress() {
    #
    TYPE=$1
    #
    # Capture and compress the resources
    log "Starting Compression $( if [[ $PIGZ ]]; then echo "using pigz"; fi )"
    #
    if [[ $PIGZ ]]; then
        fcnk "$(tar -c --use-compress-program=pigz -f "$TARGET/$DATE-$TYPE.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Compression with Pigz may have failed"
    else
        fcnk "$(tar -zcf "$TARGET/$DATE-$TYPE.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Compression may have failed"
    fi
    log "Finished Compression"
    #
}
# Summary log fnc
summary() {
    #
    # Roll over logs
    find "$TARGET/." -mtime "+$ROLLOVER" -delete
    log "Removed backups older than ($ROLLOVER) days"
    #
    log "Finished. Completed in ($(( $SECONDS - $STARTUP )))s"
}
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
#
# KVM Version
#
#
if [[ $KVM ]]; then
    #
    # Capture currently running VMs
    VMS=$(virsh list --all --name --state-running)
    #
    # If reset is enabled (-r | --reset)
    if [[ $RESET ]]; then
        #
        log "Sending shutdown-signal to running Virtual Machine(s).."
        virsh shutdown $VMS
        #
    # If pausing VMs (Default)
    else
        #
        log "Pausing memory for running Virtual Machine(s)..."
        virsh suspend $VMS
        #
    fi
    #
    # Wait for VMs to stop running
    TIMEOUT=0
    TIMEOUT_LIMIT=90
    #
    #log "Current timeout threshold is $TIMEOUT_LIMIT seconds"
    #
    DONE=false
    while ! $DONE; do
        #
        # No running VMs found
        if [[ -z $(virsh list --all --name --state-running) ]]; then
            log "VMs stopped/paused successfully"
            DONE=true
        fi
        #
        TIMEOUT=$(($TIMEOUT + 1))
        #
        if [[ $TIMEOUT == $TIMEOUT_LIMIT ]]; then log "VMs failed to stop/pause within the timeout threshold: $TIMEOUT_LIMIT second(s). This is a fatal error!"; exit 1; fi
        #
        sleep 1
        #
    done
    #
    # Compress KVM data
    compress "kvm"
    #
    # Restarting conatiners
    log "Starting Virtual Machine(s)..."
    # If reset is enabled (-r | --reset)
    if [[ $RESET ]]; then
        #
        virsh start $VMS
        #
    # If pausing VMs (Default)
    else
        #
        virsh resume $VMS
        #
    fi
    #
    # Summary
    summary
    #
    #
    exit 0
#
# Docker Version (Default) 
else
    #
    # Record currently running containers
    CURRENT_CONTAINERS="$(docker ps -q)"
    #
    #
    # If reset is needed (-R | --reset)
    if [[ $RESET ]]; then
        log "Stoping Containers"
        docker stop ${CURRENT_CONTAINERS}
    # Hard reset [1] - RM containers (-H | --hardreset)
    elif [[ -n "$HARD" ]]; then
        log "Stoping Containers"
        docker stop ${CURRENT_CONTAINERS}
        log "[Hard Reset] Deleting Containers and Networks from docker..."
        docker rm ${CURRENT_CONTAINERS}
        docker network rm $(docker network ls -q)
    # Pause Conatiners [Default] 
    else
        log "Pausing Containers"
        docker pause ${CURRENT_CONTAINERS}
    fi
    #
    # Capture and compress the containers
    compress "docker"
    #
    # Hard reset [2] - rebuild containers
    if [[ -n "$HARD" ]]; then
        log "[Hard Reset] Rebuilding Containers and Networks using dir: $HARD"
        runbulk "$HARD/networks/"
        runbulk "$HARD/containers/"
    else
        # Regular restart of the containers
        log "Starting Containers"
        docker start ${CURRENT_CONTAINERS}
    fi
    #
    # Summary
    summary
fi