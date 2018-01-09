FROM openjdk:8u131-jre-alpine

LABEL maintainer "mtraylor-spotx"

RUN apk add -U \
          openssl \
          imagemagick \
          lsof \
          su-exec \
          bash \
          curl iputils wget \
          git \
          jq \
          mysql-client \
          python python-dev py2-pip && \
        rm -rf /var/cache/apk/*

RUN pip install mcstatus

HEALTHCHECK CMD mcstatus localhost ping

RUN adduser -Ss /bin/bash -h /home/minecraft -g minecraft minecraft
RUN mkdir -p /home/minecraft/data \
  && mkdir -p /home/minecraft/config \
  && mkdir -p /home/minecraft/mods \
  && mkdir -p /home/minecraft/plugins \
  && chgrp -R 0 /home/minecraft \
  && chmod -R g=u /home/minecraft

EXPOSE 25565 25575

ADD https://github.com/itzg/restify/releases/download/1.0.4/restify_linux_amd64 /usr/local/bin/restify
ADD https://github.com/itzg/rcon-cli/releases/download/1.3/rcon-cli_linux_amd64 /usr/local/bin/rcon-cli
COPY start* /
COPY mcadmin.jq /usr/share
RUN chmod -R +x /usr/local/bin/*

VOLUME ["/home/minecraftdata","/home/minecraft/mods","/home/minecraft/config","/home/minecraft/plugins","/home/minecraft"]
COPY server.properties /tmp/server.properties
WORKDIR /home/minecraft/data
RUN chmod g=u /etc/passwd
ENTRYPOINT [ "/start" ]

USER 1000

ENV UID=1000 USER_NAME=minecraft HOME=/home/minecraft EULA=TRUE \
    MOTD="A Minecraft Server Powered by Docker" \
    JVM_XX_OPTS="-XX:+UseG1GC" MEMORY="2G" \
    TYPE=VANILLA VERSION=LATEST FORGEVERSION=RECOMMENDED SPONGEBRANCH=STABLE SPONGEVERSION= LEVEL=world \
    PVP=true DIFFICULTY=easy ENABLE_RCON=true RCON_PORT=25575 RCON_PASSWORD=minecraft \
    LEVEL_TYPE=DEFAULT GENERATOR_SETTINGS= WORLD= MODPACK= ONLINE_MODE=TRUE CONSOLE=true
