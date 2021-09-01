#!/bin/bash
source /home/lichess/.bashrc

# Run Redis in the background.
redis-server --daemonize yes

# Run lila-ws in the background.
# cd /home/lichess/projects/lila-ws
# setsid nohup sbt run &

# Run MongoDB in the background.
sudo mongod --fork --logpath /var/log/mongod.log

cd /home/lichess/projects/lila

# Update the client side modules.
# ./ui/build

# Run the Scala application
# ./lila run

bash
