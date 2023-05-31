#!/bin/bash
#
: '

OCULUS.SH
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
#
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Run Path (Rq)
    "-r" | "--RUNPATH")
        RUN_PATH=${ARGS[$ARGC+1]}
    ;;
    # Log Rotation (Opt)
    "-R" | "--ROLLOVER")
        ROLLOVER=${ARGS[$ARGC+1]}
    ;;
    # Check NVIDIA Gpu? (Opt)
    "--NVIDIA")
        NVIDIA=true
    ;;
    # Check ZFS Pool? (Opt)
    "--ZFS")
        ZFS=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Occulus Help Menu
    -r --RUNPATH   Path for run captures
    -R --ROLLOVER  Custom rollover interval. Default is 14
       --NVIDIA    Captures output of 'nvidia-smi' during the run
       --ZFS       Captures output of 'zpool status' during the run
    -h --help      This menu\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
#
# <Input Validation>
ec "$RUN_PATH" "[0x1] No Run path provided. Please use -r or --RUNPATH."
if [[ -z $ROLLOVER ]]; then log "No Rollover integer provided, defaulting to 14 days."; ROLLOVER=14; fi
#
#
# <MAIN>
#
# Initial Log
log "Start-up"
#
#
# Create Directories
# Run Path
fc "$(mkdir -p "$RUN_PATH" 2>&1)" "[0x1] Failed to Create Run Path directory '$RUN_PATH'"
# Temp Path
fc "$(mkdir -p "$TEMP_PATH" 2>&1)" "[0x1] Failed to Create Temporary directory '$TEMP_PATH'"
#
#
# Snapshot begins
log "Starting System capture"
#
# Snapshot (Regular)
who > "$TEMP_PATH/who.log"
last > "$TEMP_PATH/last.log"
ip a > "$TEMP_PATH/ip.log"
ping -c 4 8.8.8.8 > "$TEMP_PATH/ping.log" # Records if there was internet access
arp > "$TEMP_PATH/arp.log"
netstat > "$TEMP_PATH/netstat.log"
lsblk > "$TEMP_PATH/lsblk.log"
cat /proc/meminfo > "$TEMP_PATH/meminfo.log"
free -h > "$TEMP_PATH/free.log"
# (Optional)
if [[ $ZFS ]]; then zpool status > "$TEMP_PATH/zpool_stat.log"; fi
if [[ $NVIDIA ]]; then nvidia-smi > "$TEMP_PATH/nvidia-smi.log"; fi
#
log "System capture complete"
#
#
# Compress run
log "Starting compression"
#
fcnk "$(tar -zcf "$RUN_PATH/$DATE.tar.gz" -C / "${TEMP_PATH#/}" 2>&1)" "[0x1] Compression Failed!"
rm -dr "$TEMP_PATH"
log "Compression Complete"
#
# Roll over logs
find "$RUN_PATH/." -mtime "+$ROLLOVER" -delete
log "Removed captures older than ($ROLLOVER) days"
#
log "[0x0] Finished. Completed in ($(( $SECONDS - $STARTUP )))s"
