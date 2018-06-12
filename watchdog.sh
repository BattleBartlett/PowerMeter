#!/bin/bash

# Usage ./watchdog.sh TIMEOUT_MINUTES WATCHED_FILE

timeout=$1
file=$2

oneMinute=60

echo "Watchdog starting: Timeout: $timeout, File: $file"

sleep $(expr $timeout \* $oneMinute)

while [[ ! -z $(find $file -mmin -$timeout -ls) ]]; do
  sleep $oneMinute
done

echo "Watchdog file($file) has not been updated within $timeout minutes - Rebooting"

#send email start

TO="chris.bartlett@live.ca"
SUBJECT="PowerMeter Reboot"
BODY="Watchdog file($file) has not been updated within $timeout minutes - Rebooting"

# Add padding to email message
#echo -e "\n\n" > "$BODY"
#echo "$MSG" >> "$BODY"
#/echo -e "\r\n" >> "$BODY"

if [ -f "$BODY" ]
then
   # Send mail if message exists
   mail -s "$SUBJECT" "$TO" < "$BODY"
else
   echo "Sending mail failed, please try again."
   exit
fi

# Delete sent message
rm -f "$BODY"

#send email end

curl -X POST --header "Content-Type:application/json" \
    "$RESIN_SUPERVISOR_ADDRESS/v1/reboot?apikey=$RESIN_SUPERVISOR_API_KEY"

