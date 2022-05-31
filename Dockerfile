FROM golang:1.13-stretch AS launcher-builder

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

WORKDIR /root

RUN apt-get update && apt-get -y install nano unzip wget tar curl gnupg2 dos2unix python procps
RUN apt-get -y install --no-install-recommends wine64

RUN apt-get -y install xvfb x11vnc xdotool supervisor net-tools fluxbox

# Add a web UI for use purposes
WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html
RUN wget -O - https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.9.0 /root/novnc/utils/websockify

WORKDIR /app

# https://github.com/irwir/eMule
RUN wget https://github.com/irwir/eMule/releases/download/eMule_v0.60d-community/eMule0.60d_x64.zip -O /tmp/emule.zip && \
    unzip /tmp/emule.zip -d /tmp && mv /tmp/eMule0.60d/* /app

ENV WINEPREFIX /app/.wine64
ENV WINEARCH win64
ENV DISPLAY :0
    
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /app
COPY --from=launcher-builder /root/launcher /app

RUN dos2unix /app/init.sh

EXPOSE 4711/tcp 23732/tcp 23733/udp

ENTRYPOINT ["/app/init.sh"]