#! /bin/sh

# turn on bash's job control
set -m

# Start bash and put it in the background
/bin/bash &

# Start the iventoy process
/bin/bash iventoy.sh -A start

# Bring bash to the foreground
fg %1