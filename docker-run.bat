docker run ^
    --mount type=bind,source=C:\dev\lichess,target=/home/lichess/projects ^
    --publish 9663:9663 ^
    --publish 9664:9664 ^
    --publish 8212:8212 ^
    --interactive ^
    --tty ^
    --name lichess ^
    lichess
