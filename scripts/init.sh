#!/bin/sh

if [ ! -f "/data/download" ]; then
    echo "Creating download directory..."
    mkdir -p /data/download
fi

if [ ! -f "/data/tmp" ]; then
    echo "Creating tmp directory..."
    mkdir -p /data/tmp
fi

if [ ! -f "/app/config" ]; then
    echo "Creating config directory..."
    mkdir -p /app/config
fi

if [ ! -f "/app/config/preferences.ini" ]; then
    echo "Creating config file..."
    cp -n /app/preferences.ini /app/config/preferences.ini
fi

if [ "$(id -u)" = "0" ]; then
    cp -n /app/config_bak/* /app/config

    echo "Applying configuration..."
    /app/launcher

    echo "Running virtual desktop..."
    /usr/bin/supervisord -n &

fi

if [ $UID != "0" ] && [ "$(id -u)" = "0" ]; then
    echo "Fixing permissions..."
    useradd -u ${UID} -U -d /app -s /bin/false emule && \
    usermod -G users emule
    chown -R ${UID}:${GID} /data
    chown -R ${UID}:${GID} /app
    exec su -s /bin/sh -c "$0" emule
    exit $?
fi

wine /app/emule.exe
