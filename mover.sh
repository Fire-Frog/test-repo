#!/bin/bash
timestamp()
{
    date '+%D %T.%3N'
}
DEFAULT_FOLDER_FROM="$PWD/files"
DEFAULT_FOLDER_TO="$PWD/destination"
ACTION=$1
FOLDER_FROM=$2
FOLDER_TO=$3
FILE_EXT="txt"
FILE_REGEX="^([a-zA-Z0-9]+)(-{1})([0-9]+).txt$"

DEFAULT_TEXT_COPY="copied"
DEFAULT_TEXT_MOVE="moved"
DEFAULT_TEXT_DEBUG="logged"

DEFAULT_TEXT_COPY_ALT="Copying"
DEFAULT_TEXT_MOVE_ALT="Moving"
DEFAULT_TEXT_DEBUG_ALT="Logging"

ACTION_TEXT=""
ACTION_TEXT_ALT=""

echo "[$(timestamp)] Organizer started."
echo "-----------------------"

case $ACTION in
    "debug")
        echo "[$(timestamp)] Organizer is set to \"$ACTION\". Only logging will be enabled."
        ACTION_TEXT=$DEFAULT_TEXT_DEBUG
        ACTION_TEXT_ALT=$DEFAULT_TEXT_DEBUG_ALT
        ;;
    "copy")
        echo "[$(timestamp)] Organizer is set to \"$ACTION\". Files will be $DEFAULT_TEXT_COPY."
        ACTION_TEXT=$DEFAULT_TEXT_COPY
        ACTION_TEXT_ALT=$DEFAULT_TEXT_COPY_ALT
        ;;
    "move")
        echo "[$(timestamp)] Organizer is set to \"$ACTION\". Files will be $DEFAULT_TEXT_MOVE."
        ACTION_TEXT=$DEFAULT_TEXT_MOVE
        ACTION_TEXT_ALT=$DEFAULT_TEXT_MOVE_ALT
        ;;
    *)
        echo "[$(timestamp)] No action was set. Defaulting to \"debug\". Only logging will be enabled."
        ACTION="debug"
        ACTION_TEXT=$DEFAULT_TEXT_DEBUG
        ACTION_TEXT_ALT=$DEFAULT_TEXT_DEBUG_ALT
        ;;
esac

# check if folder path is sent in args
if [ -z $FOLDER_FROM ]; then
    # no args, use default folder
    echo "[$(timestamp)] No folders in args."
    echo "[$(timestamp)] Using default folders:"
    echo "[$(timestamp)] FROM  : $DEFAULT_FOLDER_FROM"
    echo "[$(timestamp)] TO    : $DEFAULT_FOLDER_TO"
    FOLDER_FROM=$DEFAULT_FOLDER_FROM
    FOLDER_TO=$DEFAULT_FOLDER_TO
else
    echo "[$(timestamp)] Folders used:"
    echo "[$(timestamp)] FROM  : $FOLDER_FROM"
    echo "[$(timestamp)] TO    : $FOLDER_TO"
fi

echo "-----------------------"

# move to directory
echo "[$(timestamp)] Moving to folder $FOLDER_FROM"
cd $FOLDER_FROM

# check folder contents
echo "[$(timestamp)] Checking folder $FOLDER_FROM"

# check amount of files
TOTAL_FILES=$(( $(ls -1 | grep -v / | wc -l) + 0 ))
TOTAL_FILES_INDEX=$(( $TOTAL_FILES-1 ))
echo "[$(timestamp)] Found $TOTAL_FILES files."

CURRENT_FILE_INDEX=0

echo "[$(timestamp)] Checking files found."
echo "-----------------------"

# go through every file
for FILE_PATH in $FOLDER_FROM/*.$FILE_EXT;
do
    # check if file is ok
    [ -e "$FILE_PATH" ] || continue
    
    # get filename
    FILENAME="$(basename $FILE_PATH)"
    
    # check if filename+ext is valid to process
    if [[ "$FILENAME" =~ $FILE_REGEX ]]
    then
        # valid, continue
        echo "[$(timestamp)] #$(($CURRENT_FILE_INDEX+1)) file \"$FILENAME\" is valid."

        # get prefix from file
        FOLDER_PREFIX=${FILENAME%%"-"*}
        UPPER_FOLDER_PREFIX=${FOLDER_PREFIX^^}
        # check if folder (using prefix) exists on destination
        echo "[$(timestamp)] Checking if folder \"$UPPER_FOLDER_PREFIX\" exists."

        if [[ ! -d "$FOLDER_TO/$UPPER_FOLDER_PREFIX" ]]; then
            # folder does not exists, create folder
            echo "[$(timestamp)] Folder \"$UPPER_FOLDER_PREFIX\" does not exists. Creating folder ..."
            
            # only create folder if action is not debug/log
            if [[ "$ACTION" != "debug" ]]; then
                mkdir $FOLDER_TO/$UPPER_FOLDER_PREFIX
            fi

            echo "[$(timestamp)] Folder \"$UPPER_FOLDER_PREFIX\" created."
        fi

        # move file
        echo "[$(timestamp)] $ACTION_TEXT_ALT file \"$FILENAME\" to folder \"$FOLDER_TO/$UPPER_FOLDER_PREFIX\""
        
        case $ACTION in
            "copy")
                cp $FILE_PATH $FOLDER_TO/$UPPER_FOLDER_PREFIX
                ;;
            "move")
                mv $FILE_PATH $FOLDER_TO/$UPPER_FOLDER_PREFIX
                ;;
        esac
        
        echo "[$(timestamp)] File \"$FILENAME\" was $ACTION_TEXT."
        
        # still there are some files to process
        if [ $CURRENT_FILE_INDEX -lt $TOTAL_FILES_INDEX ]; then
            # continue processing
            CURRENT_FILE_INDEX=$(( $CURRENT_FILE_INDEX+1 ))
        fi
    else
        # is not, skip
        echo "[$(timestamp)] File \"$FILENAME\" is not valid and will be skipped."
    fi
    
    echo -e "[$(timestamp)] Continuing..."
    echo "-----------------------"
done

echo "[$(timestamp)] Organizer $ACTION_TEXT $CURRENT_FILE_INDEX/$TOTAL_FILES files."
echo "[$(timestamp)] Organizer ended."
