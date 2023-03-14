#!/bin/sh
: '

OCULUS.SH
Gathers a snapshot of the current state of the machine.

'
#
#ROOTDIR="$(pwd)" # Debugging
ROOTDIR="/var/log/th"
DATE="$(date +"%Y-%m-%dT%H:%M:%S")"
PTDIR="$ROOTDIR/log/$DATE"
#
# Directory for the run
mkdir -p "$PTDIR"
#
# Snapshot begins
who > "$PTDIR/who.log"
last > "$PTDIR/last.log"
ip a > "$PTDIR/ip.log"
ping -c 4 8.8.8.8 > "$PTDIR/ping.log" # Records if there was internet access
arp > "$PTDIR/arp.log"
netstat > "$PTDIR/netstat.log"
zpool status > "$PTDIR/zpool_stat.log" # only for ZFS users
lsblk > "$PTDIR/lsblk.log"
top -bn5 > "$PTDIR/top.log" &
iotop -obn5 > "$PTDIR/iotop.log" &
tcpdump -c 40 > "$PTDIR/tcpdump.log"
cat /proc/meminfo > "$PTDIR/meminfo.log"
free -h > "$PTDIR/free.log"
#
# Compress run
tar -cf "$ROOTDIR/log/$DATE.tar" "$PTDIR"
rm -dr "$PTDIR"