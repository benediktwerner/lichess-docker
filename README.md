# Lichess Docker Container

Docker setup for Lichess development. Based on [BrandonE's original Lichess Docker setup](https://github.com/BrandonE/lichocker) (since that one doesn't work anymore). The directions assume you will install as an admin user into that user's $HOME folder, typically $HOME/lichess-docker, with the lila modules in $HOME/lichess-docker/dev/lichess/{lila,lila-ws}. If you do not want this installation structure, you will have trouble and need to set HOME properly.

## Usage

1. SSH into your system as admin on Linux, or as an admin account on Windows. This is referred to as session 1.
2. cd $HOME
3. Clone or download this repo and `cd` into it (e.g. git clone https://github.com/benediktwerner/lichess-docker.git, then cd lichess-docker)
4. Build the image: `docker build --tag lichess .`
5. Create the dev/lichess folder (e.g. mkdir dev then  mkdir dev/lichess). Then cd dev/lichess
6. Clone or downlod [lila](https://github.com/ornicar/lila) and [lila-ws](https://github.com/ornicar/lila-ws). It's assumed they are placed in `$HOME/dev/lichess/{lila,lila-ws}` if you're on Linux or using Windows with WSL and in `C:\dev\lichess` if you're running Docker directly from Windows. If you place them somewhere else, you'll have to modify `docker-run.sh` or `docker-run.bat` or the command below to use the correct path.
7. cd $HOME/lichess-docker
8. Create and start the container:

     - On Linux or WSL, either run `./docker-run.sh` or 
     - run this command, making sure to adjust `$HOME/dev/lichess` if you cloned lila and lila-ws to a different directory:
```
docker run \
    --mount type=bind,source=$HOME/dev/lichess,target=/home/lichess/projects \
    --publish 9663:9663 \
    --publish 9664:9664 \
    --publish 8212:8212 \
    --name lichess \
    --interactive \
    --tty \
    lichess
```

If you are starting the container directly from Windows, I strongly recommend running Docker from WSL 2 and placing lila and lila-ws in the WSL 2 file system since that will significantly speed up compilation. Optionally you can use `docker-run.bat` instead (again, make sure to adjust the mount point to the actual directory where lila and lila-ws are located).

The contianer will automatically start redis and mongo, but won't build or run any lila services. You will have to do that manually: 
8. Create two additional SSH terminal sessions (session 2 and 3)
9. In session 2, run the websocket server:
    -`docker exec -it lichess bash` 
    -`cd ~/projects/lila-ws` 
    -`sbt run
10. In session 3, build UI stuff i.e. compile SCSS and TypeScript to CSS and JavaScript:
    - `docker exec -it lichess bash` 
    - `cd ~/projects/lila/ui
    - `./build` 
    -  You should do this at least once the first time after cloning the project, and probably again every time after pulling major changes.
        - `./build dev css` to only build SCSS
        - `cd analyse` and `yarn dev` to build just the `analyse` module and similarly for other modules
        - And I also use this terminal for other miscellaneous stuff like accessing the db via `mongo lichess`.
 11. Back in the original terminal (session 1) create the DB indices:
      - `mongo lichess bin/mongodb/indexes.js`
 12.  Now we are ready to run lila itself.
     - `docker exec -it lichess-gh bash
     - ./lila` 
     -`run`
     
     
You should also read the [Lichess Development Onboarding guide](https://github.com/ornicar/lila/wiki/Lichess-Development-Onboarding#installation) on the [Lichess GitHub wiki](https://github.com/ornicar/lila/wiki) for additional instructions on seeding the db, gaining admin access, or running suplementary services like fishnet for server analysis or playing vs Stockfish

**Note**: With the run command above (14) (or `docker-run.sh`) or the start command below, the container will be stopped (but not deleted) when the main session exits, so that session always has to be kept alive and ideally should be terminated last.

## Useful commands

* Stop the Docker container: `docker stop lichess`
* Restart the Docker container and attach to it: `docker start lichess --attach --interactive`
* Open a second shell in the running container: `docker exec -it lichess bash`
* Remove the Docker container (e.g. to mount a different volume): `docker rm lichess`

## License

- `build/nvm-install.sh` is licensed under the MIT license. See the file's header.
- `build/sdkman-init.sh` is licensed under the Apache 2.0 license. See the file's header.
- All other code is in the public domain.
