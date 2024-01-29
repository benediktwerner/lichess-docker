# Lichess Docker Container

> [!CAUTION]
> This repository is not being updated anymore. Use the [official Docker setup](https://github.com/lichess-org/lila-docker) instead. Or use the [Gitpod setup](https://github.com/lichess-org/lila-gitpod) for an even simpler start.

Docker setup for Lichess development. Based on [BrandonE's original Lichess Docker setup](https://github.com/BrandonE/lichocker).

## Usage

1. Clone or download this repo and `cd` into it
2. Build the image: `docker build --tag lichess .`
3. Clone or downlod [lila](https://github.com/ornicar/lila) and [lila-ws](https://github.com/ornicar/lila-ws). It's assumed they are placed in `$HOME/dev/lichess/{lila,lila-ws}` if you're on Linux or using Windows with WSL and in `C:\dev\lichess` if you're running Docker directly from Windows. If you place them somewhere else, you'll have to modify `docker-run.sh` or `docker-run.bat` or the command below to use the correct path.
4. Create and start the container:

On Linux or WSL, either run `./docker-run.sh` or the following command (make sure to adjust `$HOME/dev/lichess` if you cloned lila and lila-ws to a different directory):
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

If you are starting the container directly from Windows, you can use `docker-run.bat` instead (again, make sure to adjust the mount point to the actual directory where lila and lila-ws are located). However, I strongly recommend running Docker from WSL 2 and placing lila and lila-ws in the WSL 2 file system since that will significantly speed up compilation.

5. The contianer will automatically start redis and mongo but won't build or run any lila services, so you will have to do that manually. I generally create two or three additional sessions using `docker exec -it lichess bash` in new terminal windows:
    - One to run `lila-ws` using `cd ~/projects/lila-ws` and `sbt run`.
    - Another in `~/projects/lila/ui` to build the client-side code there i.e. compile SCSS and TypeScript to CSS and JavaScript:
        - `./build -w` to build everything and then watch for changes and rebuild. This is quite performant nowadays so it's probably what you want.
        - `./build` just builds everything once and then exits.
        - `./build --sass` to only build SCSS
        - `./build analyse` to only build the `analyse` module and similarly for other modules
        - See the [ui readme](https://github.com/lichess-org/lila/tree/master/ui) for more details
    - Sometimes, you might want a 3rd session to run other miscellaneous stuff like accessing the db via `mongo lichess`. You might also want to check out [lila-db-seed](https://github.com/lichess-org/lila-db-seed) to populate your db with some test data.
    - And ofc, the main session will be used to run lila itself using `./lila` and then `run`. Before the first run, you should also run `mongo lichess bin/mongodb/indexes.js` to create db indices.
    - You should also read the [Lichess Development Onboarding guide](https://github.com/ornicar/lila/wiki/Lichess-Development-Onboarding#installation) on the [Lichess GitHub wiki](https://github.com/ornicar/lila/wiki) for additional instructions on seeding the db, gaining admin access, or running suplementary services like fishnet for server analysis or playing vs Stockfish

Note, that with the run command above (or `docker-run.sh`) or the start command below, the container will be stopped (but not deleted) when the main session exits, so that session always has to be kept alive and ideally should be terminated last.

## Useful commands

* Stop the Docker container: `docker stop lichess`
* Restart the Docker container and attach to it: `docker start lichess --attach --interactive`
* Open a second shell in the running container: `docker exec -it lichess bash`
* Remove the Docker container (e.g. to mount a different volume): `docker rm lichess`

## License

- `build/nvm-install.sh` is licensed under the MIT license. See the file's header.
- `build/sdkman-init.sh` is licensed under the Apache 2.0 license. See the file's header.
- All other code is in the public domain.
