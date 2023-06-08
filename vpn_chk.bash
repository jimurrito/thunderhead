#!/bin/bash
: '

VPN Check
Checks if Conatiners are properly on VPN. Kill those who do not comply!

'
#
# <CONSTANTS>
URL=https://api.ipify.org
CMDDCKR="docker exec -i"
CMDCURL="curl -sf $URL"
CMDWGET="wget -q -O /dev/stdout $URL"
#
LOGHEADER="[TH][VPNC]"
STARTUP=$SECONDS
KILL=0
#
# Log Func
log() {
    echo "$1"; logger "$LOGHEADER $1"
}
#
#
log "Start-up..."
#
CIP=$($CMDCURL)
log "Current host IP [$CIP]."
#
#
CONTS=("$@")
#
for c in "${CONTS[@]}"; do
    #
    #
    # First test - Curl
    log "Checking IP of container [$c] using curl..."
    DIP=$($CMDDCKR "$c" $CMDCURL)
    #
    # Second test - wget
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        log "Using curl failed for conatiner [$c]. Testing with wget..."
        DIP=$($CMDDCKR "$c" $CMDWGET)
    fi
    #
    # Catchall
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        log "Using both curl and wget failed for conatiner [$c]!"
        DIP=FAIL
    fi
    #
    log "Container [$c] has IP $DIP."
    #
    # We do not want these to equal
    if [[ "$DIP" == "$CIP" ]]; then
        log "Killing container [$c] for non-compliance..."
        docker kill "$c"
        KILL+=1
    elif [[ "$DIP" == "FAIL" ]]; then
        log "Pulling ip for container [$c] failed. Ignoring container..."
    else
        log "Container [$c] is compliant!"
    fi
    #
done
#
#
log "[$KILL] containers killed due to non-compliance."
log "Finished. Completed in ($(( $SECONDS - $STARTUP )))s."