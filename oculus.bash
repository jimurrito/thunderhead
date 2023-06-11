#!/bin/bash
#
: '

OCULUS
Gathers a snapshot of the current state of the machine.

'
#
# <CONSTANTS>
LOGHEADER="[TH][Oculus]"
DATE="$(date +"%Y-%m-%dT%H:%M")"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
TEMP_PATH="/tmp/th/oc/$DATE"
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
#
# No Arg Check
if [[ ${#ARGS[@]} == 0 ]]; then 
    echo "[0x1] No arguments provided. Please use -h or --help to see the required arguments."
fi
#
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Run Path (Rq)
    "-o" | "--output")
        OUT_PATH=${ARGS[$ARGC+1]}
    ;;
    # Log Rotation (Opt)
    "-r" | "--rollover")
        ROLLOVER=${ARGS[$ARGC+1]}
    ;;
    # Check NVIDIA Gpu? (Opt)
    "--nvidia")
        NVIDIA=true
    ;;
    # Check ZFS Pool? (Opt)
    "--zfs")
        ZFS=true
    ;;
    # Enable Verbose (Opt)
    "-v" | "--verbose")
        VERB=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Occulus - Help Menu
Ex: bash oculus.bash -o ./path/to/dir [ -r <days> --zfs --nvidia ]
    -o --output    [/path]      Output path for captures.
    -r --rollover  [int(days)]  Custom rollover interval; Default is 14.
       --nvidia                 Captures output of 'nvidia-smi' during the run.
       --zfs                    Captures output of 'zpool status' during the run.
    -v --verbose                Enables Verbose logging.
    -h --help                   This menu!\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
#
# <Input Validation>
# If no output path provided, use current path
if [[ -z $OUT_PATH ]]; then OUT_PATH=$(pwd);fi
# Rollover int check
if [[ -z $ROLLOVER ]]; then 
    ROLLOVER=14
    if [[ $VERB ]]; then log "No Rollover integer provided, defaulting to 14 days.";  fi
fi
#
#
# <MAIN>
#
# Initial Log
log "Start-up."
#
#
# Create Directories
# Run Path
fc "$(mkdir -p "$OUT_PATH" 2>&1)" "[0x1] Failed to Create/Access Output Path directory '$OUT_PATH'."
# Temp Path
fc "$(mkdir -p "$TEMP_PATH" 2>&1)" "[0x1] Failed to Create/Access Temporary directory '$TEMP_PATH'."
#
#
# Snapshot begins
if [[ $VERB ]]; then log "Starting System capture..."; fi
# Snapshot (Regular)
who > "$TEMP_PATH/who"
last > "$TEMP_PATH/last"
ip a > "$TEMP_PATH/ip"
ping -c 4 8.8.8.8 > "$TEMP_PATH/ping" # Records if there was internet access
arp > "$TEMP_PATH/arp"
netstat > "$TEMP_PATH/netstat"
lsblk > "$TEMP_PATH/lsblk"
cat /proc/meminfo > "$TEMP_PATH/meminfo"
free -h > "$TEMP_PATH/free"
# (Optional)
if [[ $ZFS ]]; then zpool status > "$TEMP_PATH/zpool_stat"; fi
if [[ $NVIDIA ]]; then nvidia-smi > "$TEMP_PATH/nvidia-smi"; fi
#
#
# Compress run
if [[ $VERB ]]; then log "System capture complete. Starting compression..."; fi
fcnk "$(tar -zcf "$OUT_PATH/$DATE.tar.gz" -C / "${TEMP_PATH#/}" 2>&1)" "[0x1] Message thrown during compression. The job may have failed!"
rm -dr "$TEMP_PATH"
if [[ $VERB ]]; then log "Compression Complete."; fi
#
#
# Roll over logs
find "$OUT_PATH/." -mtime "+$ROLLOVER" -delete
if [[ $VERB ]]; then log "Removed captures older than ($ROLLOVER) days."; fi
#
log "[0x0] Finished! Completed in ($(( $SECONDS - $STARTUP )))s."
