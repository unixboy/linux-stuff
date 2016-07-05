#!/bin/sh
###############################################################################
# Program        : smoke_test.sh
# Description    : This script is used to validate an intranet application
#                  is up and running.
###############################################################################
# Sub-routine Begin
log_error()
{
  if [ $1 -ne 0 ]
  then
    
    validate_log_dir
    
    echo "$2" >> "$SCRIPTPATH/$LOG_FILE"
        exit 1
  fi

  if [ ! -z $3 ]
  then
    
    validate_log_dir

    # Send an email alert to respective group
    echo "Error in retrieving URL output" >> "$SCRIPTPATH/$LOG_FILE"
    #php test.php
    exit 1
  fi
}
# Sub-routine End

# Sub-routine Begin
# Validate if the dir logs exists else create it
validate_log_dir()
{
  if ! [ -d  "$SCRIPTPATH/$LOG_DIR" ]
  then
    `mkdir $SCRIPTPATH/$LOG_DIR`
  fi
}
# Sub-routine End

SCRIPT=$(readlink -f "$0")
# Absolute path this script
SCRIPTPATH=$(dirname "$SCRIPT")

CFG_FILE="$SCRIPTPATH/smoke_test.cfg"
email_notify_flag=0

# Load the config file to inherit values specified in cfg file
. $CFG_FILE

# If above command fails, log error message, and abort the execution
log_error $? "Unable to load config file:- $CFG_FILE"

URL=$1

curl_path=`whereis curl | cut -d " " -f2`
if [ -z $curl_path ]
then
  log_error $? "Unable to retrieve CURL Command Path:- $curl_path"
fi

validate_log_dir

# Write CURL output into Log file
$curl_path -Is $URL >> "$SCRIPTPATH/$LOG_FILE"
log_error $? "Unable to write output of CURL Command into Log file"

  # Ping URL and send an alert in case of any errors
curl_output=`$curl_path -Is $URL  | awk '{print $2}' | head -1`
if [ $curl_output -ne 200 -o $? -ne 0 ]
then
  email_notify_flag=1
  log_error $? "Unable to load URL:-$URL. please check log for further details" $email_notify_flag
fi
