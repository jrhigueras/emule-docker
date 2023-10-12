FROM golang:latest AS launcher-builder

WORKDIR /root
COPY launcher /root
RUN go build -o launcher

FROM debian:stable-slim
LABEL maintainer="Dario Ragusa"

ENV UID 0
ENV GUI 0
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV WINEPREFIX /app/.wine
ENV WINEARCH win32
ENV WINEDLLOVERRIDES=mscoree=d;mshtml=d
ENV DISPLAY :0

RUN apt update && \
    apt -y install nano unzip wget tar curl gnupg2 dos2unix python-is-python3 2to3 procps && \
    apt -y install xvfb x11vnc xdotool supervisor net-tools fluxbox

RUN dpkg --add-architecture i386 && \
    apt update && \
    apt -y install wine32

# Dovesse servire è qui
# RUN dpkg --add-architecture i386 && \
#     mkdir -pm755 /etc/apt/keyrings && \
#     wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
#     wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
# RUN apt update && \
#     apt -y install --no-install-recommends winehq-stable

# Add a web UI for use purposes
RUN wget -O - https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.4.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html
RUN wget -O - https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.11.0 /root/novnc/utils/websockify

WORKDIR /app

# https://github.com/irwir/eMule
RUN wget https://github.com/irwir/eMule/releases/download/eMule_v0.70a-community/eMule0.70a.zip -O /tmp/emule.zip && \
    unzip /tmp/emule.zip -d /tmp && mv /tmp/eMule0.70a/* /app

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /app
COPY --from=launcher-builder /root/launcher /app

RUN dos2unix /app/init.sh

EXPOSE 4711/tcp 8080/tcp 23732/tcp 23733/udp

ENTRYPOINT ["/app/init.sh"]