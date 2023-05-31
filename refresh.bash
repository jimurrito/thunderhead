#!/bin/bash

: '
refresh.bash

Restarts and updates all docker conatiners

'
#
#
LOGHEADER="[TH][Refresh]"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
#
#
# Log Func
log() {
    echo "$1"; logger "$LOGHEADER $1"
}
# Fail Check Function
fc() {
    if [[ -n $1 ]]; then log "$2 ErrorMsg($1)"; exit 1; fi
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
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Path to the docker run files (Rq)
    "-r" | "--runscripts")
        RUN_PATH=${ARGS[$ARGC+1]}
    ;;
    # Log Rotation (Opt)
    "--CONFIRM")
        CONFIRM=true
    ;;
    "-S" | "--silence")
        SILENT=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Refresh Help Menu\nWARNING! THIS SCRIPT CAN DESTROY ALL DOCKER DATA IF IMPROPERLY USED. YOU HAVE BEEN WARNED! ;p
    -r --runscripts  Path to the scripts used to build the docker enviroment
       --CONFIRM     Confirm running the operation (Required)
    -S --silent      Silences the warning message at the begining of the run
    -h --help        This menu\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
# Input check and per-run warning
ec "$RUN_PATH" "[0x1] No path to the run scripts provided. Please use -r or --runscripts."
if [[ -z $SILENT ]]; then  echo "WARNING! THIS OPERATION WILL DESTROY ALL DOCKER DATA IF IMPROPERLY USED. YOU HAVE BEEN WARNED! ;p"; fi
ec "$CONFIRM" "[0X1] '--CONFIRM' is required to run the script. Please add it to your command to continue."
#
# <Main>
#
log "Stoping Containers."
docker stop $(docker ps -qa)
#
log "Pruning all docker data."
docker system prune -fa
#
log "Rebuilding Docker Networks."
runbulk "$RUN_PATH/networks/"
#
log "Rebuilding Docker Containers."
runbulk "$RUN_PATH/containers/"
#
log "[0x0] Refresh completed successfully. Operation finished in ($(( $SECONDS - $STARTUP )))"