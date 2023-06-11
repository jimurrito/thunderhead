#!/bin/bash

: '
Refresh

Updates all docker conatiner images. Rebuilds docker enviroment as a result.

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
#
# No Arg Check
if [[ ${#ARGS[@]} == 0 ]]; then 
    echo "[0x1] No arguments provided. Please use -h or --help to see the required arguments."
fi
#
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Path to the docker run files (Rq)
    "-r" | "--runscripts")
        RUN_PATH=${ARGS[$ARGC+1]}
    ;;
    # Log Rotation (Opt)
    "-C" | "--CONFIRM")
        CONFIRM=true
    ;;
    "-S" | "--silence")
        SILENT=true
    ;;
    # Enable Verbose (Opt)
    "-v" | "--verbose")
        VERB=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Refresh - Help Menu\nWARNING! THIS SCRIPT CAN DESTROY ALL DOCKER DATA IF IMPROPERLY USED. YOU HAVE BEEN WARNED! ;p
Ex: bash refresh.bash -r ./runscripts --CONFIRM [ -S -v ]
    -r --runscripts  [/path]  Path to the scripts used to build the docker enviroment.
    -C --CONFIRM              Confirm running the operation (Required).
    -S --silent               Silences the warning message at the begining of the run.
    -v --verbose              Enables verbose logging.
    -h --help                 This menu!\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
3
# Run scripts BULK
runbulk() {
    for i in $( ls "$1"*.sh | grep -v DEP ); do
        if [[ $VERB ]]; then log "Recreating '$i'..."; fi
        bash "$i"
    done
}
#
# Input check and per-run warning
ec "$RUN_PATH" "[0x1] No path to the run scripts provided. Please use -r or --runscripts."
if [[ -z $SILENT ]]; then  echo "WARNING! THIS OPERATION WILL DESTROY ALL DOCKER DATA IF IMPROPERLY USED. YOU HAVE BEEN WARNED! ;p"; fi
ec "$CONFIRM" "[0X1] '-C' or '--CONFIRM' is required to run the script. Please add it to your command to continue."
#
# <Main>
log "Start-up"
#
if [[ $VERB ]]; then log "Stoping Containers..."; fi
docker stop $(docker ps -qa)
#
if [[ $VERB ]]; then log "Pruning all docker data..."; fi
docker system prune -fa
#
if [[ $VERB ]]; then log "Rebuilding Docker Networks..."; fi
runbulk "$RUN_PATH/networks/"
#
if [[ $VERB ]]; then log "Rebuilding Docker Containers..."; fi
runbulk "$RUN_PATH/containers/"
#
log "[0x0] Refresh completed successfully. Operation finished in ($(( $SECONDS - $STARTUP )))s."