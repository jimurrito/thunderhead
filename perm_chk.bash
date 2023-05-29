#!/bin/sh
: '

PERM_CHK.SH
Sets file permissions in bulk for a filesystem.

'
#
# Functions
ch_resolve() {
    # Converts 3 digit chmod numbers into a string
    OUT=$1
    OUT=${OUT//7/"rwx"}
    OUT=${OUT//6/"rw-"}
    OUT=${OUT//5/"r-x"}
    OUT=${OUT//4/"r--"}
    OUT=${OUT//3/"-wx"}
    OUT=${OUT//2/"-w-"}
    OUT=${OUT//1/"--x"}
    OUT=${OUT//0/"---"}
    #
    echo "$OUT"
}
#
# <CONSTANTS>
LOGHEADER="[TH][perm_chk]"
STARTUP=$SECONDS
ARGC=0
ARGS=("$@")
#
# Log Func
log() {
    MSG="$LOGHEADER $1"
    echo "$MSG"; logger "$MSG"
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
#
# Parse Input Vars
for ARG in "${ARGS[@]}"; do
    case $ARG in
    # Target Path (Rq)
    "-p" | "--path")
        DIR=${ARGS[$ARGC+1]}
    ;;
    # Chmod code (rq)
    "-c" | "--chmod")
        CHMOD=${ARGS[$ARGC+1]}
    ;;
    # Owner name (Opt)
    "-o" | "--owner")
        OWNER=${ARGS[$ARGC+1]}
    ;;
    # Check NVIDIA Gpu? (Opt)
    "-v" | "--verbose")
        VERB=true
    ;;
    # Help menu
    "-h" | "--help")
        printf "Thunderhead - Perm_Chk Help Menu\nEx: bash perm_chk.bash -p </path/to/dir> -c <int> [OPTIONS] 
    -p --path      Path to target directory/file
    -c --chmod     Desired Chmod permission
    -o --owner     Desired Owner of directory/file(s)
    -v --verbose   Enables verbose logging
    -h --help      This menu\n"
        exit
    ;;
    esac
    # Iterate
    ARGC=$(($ARGC + 1))
done
#
# <Input Validation>
# Directory path validation
if [[ -z "$DIR" ]]; then
    # No directory provided
    echo "No directory path provided. Please use -h or --help to see required arguments."
    exit 1
# chmod permission validation
elif [[ -z "$CHMOD" ]]; then
    # No directory provided
    echo "No chmod permission number provided. Please use -h or --help to see required arguments."
    exit 1
fi
#
# <MAIN>
#
# Initial Log
log "Start-up. Working directory: $DIR"
#




#
exit
#
# Set owner for dir
logger "$LOGHEADER Setting directory(s) owner to '$FOWNR'"
chown -vR "$FOWNR:$FOWNR" $DIR
#
# Set file permissions
logger "$LOGHEADER Setting directory permissions to '$CHMOD'"
chmod -vR $CHMOD $DIR
#
#
logger "$LOGHEADER Finished. Completed in ($(( $SECONDS - $STARTUP )))s"