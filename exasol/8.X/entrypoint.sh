#!/bin/bash

/init.sh &

exec /opt/exasol/cos-8.51.0/docker/exadt init-sc

