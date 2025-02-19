FROM golang:latest AS launcher-builder

WORKDIR /root
COPY launcher /root
RUN go build -o launcher

FROM debian:bookworm-slim
LABEL maintainer="Juan Ramón Higueras Pica"

ENV UID=0
ENV GID=0
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV WINEPREFIX=/app/.wine
ENV WINEARCH=win64
ENV WINEDLLOVERRIDES=mscoree=d;mshtml=d
ENV DISPLAY=:0

RUN apt update && \
    apt -y install nano unzip wget tar curl gnupg2 dos2unix python-is-python3 2to3 procps git && \
    apt -y install xvfb x11vnc xdotool supervisor net-tools fluxbox

RUN dpkg --add-architecture i386 && \
    mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN apt update && \
    apt -y install --no-install-recommends winehq-stable

# Add a web UI for use purposes
RUN git clone https://github.com/novnc/noVNC/ && ln -s /noVNC/vnc.html /noVNC/index.html
RUN git clone https://github.com/novnc/websockify/ && mv /websockify /noVNC/utils/websockify

WORKDIR /app

# https://github.com/irwir/eMule
RUN wget https://github.com/irwir/eMule/releases/download/eMule_v0.70b-community/eMule0.70b.zip -O /tmp/emule.zip && \
    unzip /tmp/emule.zip -d /tmp && mv /tmp/eMule0.70b/* /app && cp -r /app/config /app/config_bak

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /app
COPY --from=launcher-builder /root/launcher /app

# Copy default settings
COPY config/preferences.ini /app/preferences.ini

RUN dos2unix /app/init.sh

EXPOSE 4711/tcp 8080/tcp 23732/tcp 23732/udp 23735/udp

ENTRYPOINT ["/app/init.sh"]
