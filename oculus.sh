#!/bin/sh
: '

OCULUS.SH
Gathers a snapshot of the current state of the machine.

'
# <Log-Rollover>
ROLLOVER_INT=14
#
# <VARS>
ROOTDIR="/var/log/th"
DATE="$(date +"%Y-%m-%dT%H:%M:%S")"
PTDIR="$ROOTDIR/log/$DATE"
STARTUP=$SECONDS
#
# <RUN>
#
# Initial Log
LOGHEADER="[TH] [Oculus.sh]"
logger "$LOGHEADER Start-up"
#
# Directory for the run
mkdir -p "$PTDIR"
#
# Snapshot begins
logger "$LOGHEADER Starting System capture"
who > "$PTDIR/who.log"
last > "$PTDIR/last.log"
ip a > "$PTDIR/ip.log"
ping -c 4 8.8.8.8 > "$PTDIR/ping.log" # Records if there was internet access
arp > "$PTDIR/arp.log"
netstat > "$PTDIR/netstat.log"
zpool status > "$PTDIR/zpool_stat.log" # only for ZFS users
lsblk > "$PTDIR/lsblk.log"
cat /proc/meminfo > "$PTDIR/meminfo.log"
free -h > "$PTDIR/free.log"
nvidia-smi -h > "$PTDIR/nvidia-smi.log"
logger "$LOGHEADER System capture complete"
#
# Compress run
logger "$LOGHEADER Starting compression"
tar -zcf "$ROOTDIR/log/$DATE.tar.gz" "$PTDIR"
rm -dr "$PTDIR"
logger "$LOGHEADER Compression Complete"
#
# Roll over logs
find "$ROOTDIR/log/." -mtime "+$ROLLOVER_INT" -delete
logger "$LOGHEADER Removing captures older than ($ROLLOVER_INT) days"
#
logger "$LOGHEADER Finished. Completed in ($(( $SECONDS - $STARTUP )))s"
