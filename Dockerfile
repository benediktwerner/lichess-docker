FROM ubuntu:focal-20221130

SHELL ["/bin/bash", "-c"]

RUN useradd -ms /bin/bash lichess \
    && apt-get update \
    && apt update \
    && apt-get install -y sudo gnupg ca-certificates\
    # Disable sudo login for the new lichess user.
    && echo "lichess ALL = NOPASSWD : ALL" >> /etc/sudoers

ENV TZ=Etc/GMT
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && sudo echo $TZ > /etc/timezone

# Run as a non-privileged user.
USER lichess

ADD build /home/lichess/build

# mongodb
RUN sudo apt-key add /home/lichess/build/signatures/mongodb.asc \
  && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org.list

RUN sudo apt-get update && sudo apt update \
  && sudo apt-get install -y \
  unzip \
  zip \
  curl \
  mongodb-org \ 
  parallel \ 
  && sudo apt install -y \ 
  redis-server \
  git-all \
  vim

# nvm => node => pnpm
RUN source /home/lichess/build/nvm-install.sh \
  && export NVM_DIR="$HOME/.nvm" \
  && source "$NVM_DIR/nvm.sh" \
  && nvm install 19 \
  && npm install -g pnpm

# Java
RUN /home/lichess/build/sdkman-init.sh \
  && source /home/lichess/.sdkman/bin/sdkman-init.sh \
  && sdk install java 17.0.5-tem && sdk install sbt

# Silence the parallel citation warning.
RUN sudo mkdir -p ~/.parallel && sudo touch ~/.parallel/will-cite

# Make directories for mongodb
RUN sudo mkdir -p /data/db && sudo chmod 666 /data/db

# Cleanup
RUN sudo apt-get autoremove -y \
  && sudo apt-get clean \
  && sudo rm -rf /home/lichess/build

ADD run.sh /home/lichess/run.sh

# Use UTF-8 encoding.
ENV LANG "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"

WORKDIR /home/lichess

ENTRYPOINT ./run.sh
