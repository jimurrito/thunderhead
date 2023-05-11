#!/bin/sh
: '

PERM_CHK.SH
Sets file permissions in bulk for a filesystem.

'
#
# <Example>
EXMP="Ex: bash perm_chk.sh [/path/to/dir] [owner] [chmod#]"
#
# <Input Validation>
# Directory path validation
if [ "$1" = "" ]; then
    # No directory provided
    echo "No directory path provided. $EXMP"
    exit 1
#
# Owner validation
elif [ "$2" = "" ]; then
    # No Owner provided
    echo "No owner provided. $EXMP"
    exit 1
#
# chmod permission validation
elif [ "$3" = "" ]; then
    # No directory provided
    echo "No chmod permission number provided. Defaulting to '777'"
    CHMOD=777
# All Validation succeeded, apply chmod value to var.
else
    CHMOD=$3
fi
#
#
# <Vars>
STARTUP=$SECONDS
DIR=$1
FOWNR=$2
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