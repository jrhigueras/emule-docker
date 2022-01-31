FROM golang:1.13-stretch AS launcher-builder

WORKDIR /root
COPY launcher /root
RUN go build -o launcher

FROM ubuntu:bionic
LABEL maintainer="Dario Ragusa"

ENV UID 0
ENV GUI 0
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /root

RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get -y install libnghttp2-14 && \
    apt-get -y install nano unzip wget tar curl gnupg software-properties-common xvfb xdotool supervisor net-tools fluxbox --fix-missing

ENV WINEDLLOVERRIDES=mscoree=d;mshtml=d
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \
    add-apt-repository ppa:cybermax-dexter/sdl2-backport && \
    apt-get -y install winehq-stable --fix-missing

RUN apt-get -y install dos2unix

# Add a web UI for debug purposes
RUN apt-get update && apt-get -y install x11vnc
WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html
RUN wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.9.0 /root/novnc/utils/websockify

WORKDIR /app

RUN curl https://www.emule-project.net/files/emule/eMule0.60d.zip --output /tmp/emule.zip && \
    unzip /tmp/emule.zip -d /tmp && mv /tmp/eMule0.60d/* /app

ENV WINEPREFIX /app/.wine
ENV WINEARCH win32
ENV DISPLAY :0
    
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /app
COPY --from=launcher-builder /root/launcher /app
COPY config/emule /app/config

RUN dos2unix /app/init.sh

EXPOSE 4711/tcp 23732/tcp 23733/udp
VOLUME /app/config /data

ENTRYPOINT ["/app/init.sh"]
