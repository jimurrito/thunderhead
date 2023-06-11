#!/bin/bash
: '

Archive
Basic script for archiving files.

'
#
# <Constants>
LOGHEADER="[TH][Archive]"
DATE="$(date +"%Y-%m-%dT%H:%M")"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
#
# <Functions>
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
#
# No Arg Check
if [[ ${#ARGS[@]} == 0 ]]; then 
    echo "[0x1] No arguments provided. Please use -h or --help to see the required arguments."
    exit 1
fi
#
# <Args>
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # source Path (Rq)
    "-s" | "--source")
        SOURCE=${ARGS[$ARGC+1]}
    ;;
    # target Path for the backup (Rq)
    "-t" | "--target")
        TARGET=${ARGS[$ARGC+1]}
    ;;
    # Backup rotations (Opt)
    "-r" | "--rollover")
        ROLLOVER=${ARGS[$ARGC+1]}
    ;;
    # Use Pigz instead of gzip (Opt)
    "--pigz")
        PIGZ=true
    ;;
    # Enable Verbose (Opt)
    "-v" | "--verbose")
        VERB=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Archive - Help Menu
Ex: bash archive.bash -s ./source -t ./target [ -r <days> -v --pigz ]
    -s --source    [/path]      Source path to data.
    -t --target    [/path]      Path to dump archive data.
    -r --rollover  [int(days)]  Custom rollover interval; Default is 14.
       --pigz                   Uses pigz for compression instead of gzip.
    -v --verbose                Enables Verbose logging.
    -h --help                   This menu!\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
# <Input Validation>
# (Fatals)
ec "$SOURCE" "[0x1] No Source directory provided. Please use -h or --help to see required arguments."
ec "$TARGET" "[0x1] No Target directory provided. Please use -h or --help to see required arguments."
# (Corrective)
# Rollover int check
if [[ -z $ROLLOVER ]]; then 
    ROLLOVER=14
    if [[ $VERB ]]; then log "No Rollover integer provided, defaulting to 14 days.";  fi
fi
# Fix for bug when source is '.'
if [[ "$SOURCE" == "." ]]; then SOURCE=$(pwd); fi
#
# <Post Val functions>
# Compress Function
compress() {
    #
    TYPE=$1
    #
    # Capture and compress the resources
    if [[ $VERB ]]; then log "Starting Compression$( if [[ $PIGZ ]]; then echo " using pigz"; fi )..."; fi
    #
    if [[ $PIGZ ]]; then
        fcnk "$(tar -c --use-compress-program=pigz -f "$TARGET/$DATE-$TYPE.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Message thrown during PIGZ compression. The job may have failed!"
    else
        fcnk "$(tar -zcf "$TARGET/$DATE-$TYPE.tar.gz" -C / "${SOURCE#/}/." 2>&1)" "[0x1] Message thrown during compression. The job may have failed!"
    fi
    if [[ $VERB ]]; then log "Compression Complete."; fi
    #
}
# Summary log fnc
summary() {
    #
    # Roll over logs
    find "$TARGET/." -mtime "+$ROLLOVER" -delete
    if [[ $VERB ]]; then log "Removed backups older than ($ROLLOVER) days."; fi
    #
    log "Finished. Completed in ($(( $SECONDS - $STARTUP )))s."
}
#
#
# <MAIN>
#
# Initial Log
log "Start-up. Backing up [$SOURCE]..."
#
# Create backup dir if does not exist
fc "$(mkdir -p "$TARGET" 2>&1)" "[0x1] Failed to Create/Access Target directory '$TARGET'."
#
# Pull the bottom level dir from the target path
PATHRAY=(${SOURCE//// })
BOTDIR=${PATHRAY[-1]}
#
compress $BOTDIR
#
# <Summary>
summary
