#!/bin/bash

docker run \
    --mount type=bind,source=$HOME/dev/lichess,target=/home/lichess/projects \
    --publish 9663:9663 \
    --publish 9664:9664 \
    --publish 8212:8212 \
    --name lichess \
    --interactive \
    --tty \
    lichess
