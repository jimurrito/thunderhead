#!/bin/bash
: '

VPN Check
Checks if Conatiners are properly on VPN. Kill those who do not comply!

'
#
# <CONSTANTS>
URL=https://api.ipify.org
CMD="curl -sf $URL"
#
LOGHEADER="[TH][VPNC]"
STARTUP=$SECONDS
KILL=0
#
# Log Func
log() {
    echo "$1"; logger "$LOGHEADER $1"
}
# wget method
wgetM() {
    C=$1
    U=$2
    docker exec -it "$C" wget -q "$U" 2> /dev/null
    OUT=$(docker exec -it "$C" cat /index.html)
    docker exec -it "$C" rm -f /index.html
    echo "$OUT"
}
#
#
log "Start-up"
#
CIP=$($CMD)
log "Current host IP: $CIP"
#
#
CONTS=("$@")
#
for c in "${CONTS[@]}"; do
    #
    log "Checking IP of container: $c, using curl..."
    #
    # First test - Curl
    DIP=$(docker exec -ti "$c" $CMD)
    #
    # Second test - wget
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        log "Using curl failed for conatiner: $c testing with wget..."
        DIP=$(wgetM "$c" "$URL")
    fi
    # Catchall
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        log "Using both curl and wget failed for conatiner: $c skipping container..."
        DIP=FAIL
    fi
    #
    log "Container: $c, has IP $DIP"
    #
    # We do not want these to equal
    if [[ "$DIP" == "$CIP" ]]; then
        log "Killing container: $c"
        docker kill "$c"
        KILL+=1
    else
     log "Container: $c is compliant"
    fi
    #
done
#
#
log "[$KILL] containers killed due to non-compliance."
log "Finished. Completed in ($(( $SECONDS - $STARTUP )))s"