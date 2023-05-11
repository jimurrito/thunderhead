#!/bin/sh
: '

PERM_CHK.SH
Sets file permissions in bulk for a filesystem.

'
#
# <Input Validation>
if [ "$1" = "" ]; then
    # No directory provided
    echo "No directory path provided. Ex: bash perm_chk.sh /path/to/dir"
    exit 1
fi

# <Vars>
CHMOD=777 # RWX RWX RWX
FOWNR="root"
DIR="$1"
STARTUP=$SECONDS
#
# <RUN>
#
# Initial Log
LOGHEADER="[TH] [Perm_chk.sh]"
logger "$LOGHEADER Start-up. Working directory: $DIR"
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