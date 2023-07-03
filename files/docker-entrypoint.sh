#!/usr/bin/env bash

# Copy default files if missing
FILE=$IVENTOY_DIR_ENV/data/iventoy.dat
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE is missing; copying default file" ;
    cp  $IVENTOY_DIR_ENV/default_files/data/iventoy.dat $FILE
fi

FILE=$IVENTOY_DIR_ENV/data/mac.db
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE is missing; copying default file" ;
    cp  $IVENTOY_DIR_ENV/default_files/data/mac.db $FILE
fi

FOLDER=$IVENTOY_DIR_ENV/user/scripts
if [ -d "$FOLDER" ]; then
    echo "$FOLDER exists."
else 
    echo "$FOLDER is missing; copying default scripts folder" ;
    cp -R $IVENTOY_DIR_ENV/default_files/user/scripts $FOLDER
fi

# Start the iventoy process
/bin/bash iventoy.sh start

IVENTOY_PID=$(cat /var/run/iventoy.pid)

# SIGTERM-handler
term_handler() {
  if [ $IVENTOY_PID -ne 0 ]; then
    kill -SIGTERM "$IVENTOY_PID"
    tail --pid=$IVENTOY_PID -f /dev/null
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'kill ${!}; term_handler' SIGTERM

# wait forever and ouput log to docker output
while true
do
  tail -f $IVENTOY_DIR_ENV/log/log.txt & wait ${!}
done
