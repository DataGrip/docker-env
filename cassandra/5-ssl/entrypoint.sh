#!/bin/bash

(/init.sh >> /var/log/init.log 2>&1) &

exec /usr/local/bin/docker-entrypoint.sh "$@"