# Lichess Docker Container

Docker setup for Lichess development. Based on [BrandonE's original Lichess Docker setup](https://github.com/BrandonE/lichocker) (since that one doesn't work anymore). The directions assume you will install as an admin user into that user's $HOME folder, typically $HOME/lichess-docker, with the lila modules in $HOME/dev/lichess/{lila,lila-ws}. If you do not want this installation structure, you will have trouble and need to set HOME properly.

Also note that by default docker must be run using sudo. Add your admin to the docker group (e.g. sudo usermod -aG docker $USER).

# Requirements
You must install the following first if they are not already available:

git (e.g. https://linuxopsys.com/topics/install-git-on-debian)
docker (e.g. https://docs.docker.com/engine/install/debian/)
    - NOTE: Be sure to use the Post-installation documentation also, to set up your docker group and make docker start at boot

## Usage

1. SSH into your system as admin on Linux, or as an admin account on Windows. This is referred to as session 1.
2. cd $HOME
3. Clone or download this repo and `cd` into it (e.g. git clone https://github.com/benediktwerner/lichess-docker.git, then cd lichess-docker)
4. Build the image: `docker build --tag lichess .`
5. Still in #HOME, create the dev/lichess folder (e.g. mkdir dev then  mkdir dev/lichess). Then cd dev/lichess
6. Clone or downlod [lila](https://github.com/ornicar/lila) and [lila-ws](https://github.com/ornicar/lila-ws). It's assumed they are placed in `$HOME/lichess-docker/dev/lichess/{lila,lila-ws}` if you're on Linux, or using Windows with WSL.  if you're running Docker directly from Windows, in `C:\dev\lichess` . If you place them somewhere else, you'll have to modify `docker-run.sh` or `docker-run.bat` or the command below to use the correct path.
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
The docker container will automatically start redis and mongo, but won't build or run any lila services. You will have to do that manually, as follows.

To reduce setup time, create two additional SSH terminal sessions (session 2 and 3) 

9. In session 2, run the websocket server: 
    - `docker exec -it lichess bash` 
    - `cd ~/projects/lila-ws` 
    - `sbt run
    - NOTE: At first setup, mongo will not be running yet. If you see something like this it can be saferly ignored:
         - INFO l.w.n.NettyServer [sbt-bg-threads-1] Listening to 9664
          WARN r.c.a.MongoDBSystem [reactivemongo-akka.actor.default-dispatcher-7] [Supervisor-1/Connection-2] The entire node set is unreachable, is there a network problem?
          ERROR r.c.a.MongoDBSystem [epollEventLoopGroup-3-1] [Supervisor-1/Connection-1] Fails to send a isMaster request to localhost:27017 (channel #52dc76c8)
          reactivemongo.io.netty.channel.StacklessClosedChannelException: null
	          at reactivemongo.io.netty.channel.AbstractChannel$AbstractUnsafe.write(Object, ChannelPromise)(Unknown Source)
          WARN r.c.a.MongoDBSystem [reactivemongo-akka.actor.default-dispatcher-6] [Supervisor-1/Connection-1] The entire node set is unreachable, is there a network problem?
          WARN r.a.MongoConnection [reactivemongo-akka.actor.default-dispatcher-6] [Supervisor-1/Connection-2] Timeout after 8200 milliseconds while probing the connection monitor: IsPrimaryAvailable#1534433389?
          
10. In session 3, build UI stuff i.e. compile SCSS and TypeScript to CSS and JavaScript:
    - `docker exec -it lichess bash` 
    - `cd ~/projects/lila/ui
    - `./build` 
    - If you see the following it can be safely ignored:
         - perl: warning: Please check that your locale settings:
	      LANGUAGE = (unset),
	      LC_ALL = (unset),
	      LC_CTYPE = "en_US.UTF-8",
	      LANG = "en_US.UTF-8"
           are supported and installed on your system.
           perl: warning: Falling back to the standard locale ("C").
           perl: warning: Setting locale failed.

    -  You should do step 10 at least once the first time after cloning the project, and probably again every time after pulling major changes.
    -  NOTES:
        - `./build dev css` to only build SCSS
        - `cd analyse` and `yarn dev` to build just the `analyse` module and similarly for other modules
        - And I also use this terminal for other miscellaneous stuff like accessing the db via `mongo lichess`.
 11. Back in the original terminal (session 1) create the DB indices:
      - `docker exec -it lichess bash` 
      - `cd ~/projects/lila`
      - `mongo lichess bin/mongodb/indexes.js`
 12.  Now we are ready to run lila itself.
     - `./lila` 
     If all went well you will see the lila prompt. Enter the run command.
     - [lila] run
     This will update a huge amount of files, pulling from https://raw.githubusercontent.com/lichess-org, https://repo1.maven.org
          and then compile the Scala sources into ~projects/lila/modules/... 
     When completed you will see the lila prompt again.
     In your session 2 window (sbt run) you will see LILA connect:
          INFO lila.ws.LilaHandler [lettuce-epollEventLoop-4-1] #################### LILA BOOT ####################
          INFO lila.ws.LilaHandler [lettuce-epollEventLoop-4-2] #################### LILA VERSIONING READY ####################
13.  If we are running lichess on a machine other than our desktop:
     Let's configure our lila and lila-ws to use the actual installation host info
     - Edit ~/projects/lila/conf/application.conf to add something like this:
       ...
       # override values from base.conf here
       net.domain = "<your_ip>:9663"
       net.asset.domain = "<your_ip>:9663"
       net.asset.base_url = "http://<your_ip>:9663"
       net.base_url = "http://<your_ip>:9663"
       net.socket.domains = [ "<your_ip:9664" ]
    - Edit ~.projects/lila-ws/src/main/resources/application.conf to add something like this:
       http.port = 9664
       mongo.uri = "mongodb://localhost:27017/lichess?appName=lila-ws"
       study.mongo.uri = ${mongo.uri}
       redis.uri = "redis://127.0.0.1"
       csrf.origin = "http://<your_ip>:9663"
       netty.useEpoll = false
       ...
  After saving the changes above, we need to restart the docker:
    - exit the docker, returning to your admin prompt
    - docker stop lichess (your other windows will be kicked out of docker when complete)
    - docker start lichess --attach --interactive (your directorry will become ~projects/lila)
    - ./lila
    At the lila prompt:
    - [lila] run
       
14. We can now connect to lichess from the browser:
     - Visit <your host ip>:9663 in the browser
     In the terminal session with [lila] run, you will see the logging of the connection.
     
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
