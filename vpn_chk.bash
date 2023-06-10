#!/bin/bash
: '

VPN Check
Checks if Conatiners are properly on VPN. Kill those who do not comply!
*For the paranoid in all of us...*

'
#
# <CONSTANTS>
#
LOGHEADER="[TH][VPNC]"
STARTUP=$SECONDS
KILL=0
ARGC=0
ARGS=("$@")
#
# Log Func
log() {
    echo "$1"; logger "$LOGHEADER $1"
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
    # Enable Verbose (Opt)
    "-u" | "--url")
        URL=${ARGS[$ARGC+1]}
    ;;
    # Enable Verbose (Opt)
    "-v" | "--verbose")
        VERB=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - VPN Check - Help Menu
Ex: bash vpn_chk.bash [OPTIONS] docker1 docker2 ...
    -u --url      [http://...]  Custom url for IP query. Use at your own risk.
    -v --verbose                Enables verbose logging.
    -h --help                   This menu!\n"
        exit
    ;;
    # Create container obj
    *)
        # Creates obj from all remaining args
        CONTS=(${ARGS[@]:$((ARGC)):${#ARGS[@]}})
        break
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
# <Main>
#
#
log "Start-up..."
#
# <Input Validatiom>
# Fatal
ec "${CONTS[@]}" "[0x1] No Containers provided. Please use -h or --help to see examples."
# Corrective
if [[ -z "$URL" ]]; then URL=https://api.ipify.org; fi
#
# CMD Templates
CMDDCKR="docker exec -i"
CMDCURL="curl -sf $URL"
CMDWGET="wget -q -O /dev/stdout $URL"
#
# <Main>
#
# Pull host IP for baseline
CIP=$($CMDCURL)
# Check if response is an IP - Run inner if not an IP
if ! [[ "$CIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    log "[0x1] API request to the URL: $URL failed. Response was not an IPv4 Address: $CIP"
    exit 1
fi
if [[ $VERB ]]; then log "Current host IP [$CIP]."; fi
#
#
# loop through containers and pull the IP Addresses
for c in "${CONTS[@]}"; do
    #
    #
    # First test - Curl
    if [[ $VERB ]]; then log "Checking IP of container [$c] using curl..."; fi
    DIP=$($CMDDCKR "$c" $CMDCURL)
    #
    # Second test - wget
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        if [[ $VERB ]]; then log "Using curl failed for conatiner [$c]. Testing with wget..."; fi
        DIP=$($CMDDCKR "$c" $CMDWGET)
    fi
    #
    # Catchall
    if ! [[ "$DIP" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        if [[ $VERB ]]; then log "Using both curl and wget failed for conatiner [$c]!"; fi
        DIP=FAIL
    fi
    #
    if [[ $VERB ]]; then log "Container [$c] has IP $DIP."; fi
    #
    # We do not want these to equal
    if [[ "$DIP" == "$CIP" ]]; then
        if [[ $VERB ]]; then log "Killing container [$c] for non-compliance..."; fi
        docker kill "$c"
        KILL+=1
    elif [[ "$DIP" == "FAIL" ]]; then
        if [[ $VERB ]]; then log "Pulling IP for container [$c] failed. Ignoring container..."; fi
    else
        if [[ $VERB ]]; then log "Container [$c] is compliant!"; fi
    fi
    #
done
#
#
log "Finished! [${#CONTS[@]}] container(s) scanned. [$KILL] container(s) killed due to non-compliance. Completed in ($(( $SECONDS - $STARTUP )))s."