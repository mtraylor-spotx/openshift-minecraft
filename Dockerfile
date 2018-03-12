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
    rm -rf /var/cache/apk/* && \
    pip install mcstatus && \
    mkdir -p /home/minecraft/data && \
    mkdir -p /home/minecraft/config && \
    mkdir -p /home/minecraft/mods && \
    mkdir -p /home/minecraft/plugins && \
    chgrp -R 0 /home/minecraft && \
    chmod -R g=u /home/minecraft

HEALTHCHECK CMD mcstatus localhost ping

EXPOSE 31565 31575

ADD https://github.com/itzg/restify/releases/download/1.0.4/restify_linux_amd64 /usr/local/bin/restify
ADD https://github.com/itzg/rcon-cli/releases/download/1.3/rcon-cli_linux_amd64 /usr/local/bin/rcon-cli
COPY start* /
COPY mcadmin.jq /usr/share
RUN chmod -R +x /usr/local/bin/*

COPY server.properties /tmp/server.properties
WORKDIR /home/minecraft/data
RUN chmod g=u /etc/passwd
ENTRYPOINT [ "/start" ]

USER 1000

ENV UID=1000 USER_NAME=minecraft HOME=/home/minecraft EULA=TRUE \
    MOTD="A Minecraft Server Powered by Openshift" \
    JVM_XX_OPTS="-XX:+UseG1GC" MEMORY="3G" \
    TYPE=VANILLA VERSION=LATEST FORGEVERSION=RECOMMENDED SPONGEBRANCH=STABLE SPONGEVERSION= LEVEL=world \
    PVP=true DIFFICULTY=easy ENABLE_RCON=true RCON_PORT=31575 RCON_PASSWORD=minecraft \
    LEVEL_TYPE=DEFAULT GENERATOR_SETTINGS= WORLD= MODPACK= ONLINE_MODE=TRUE CONSOLE=true
