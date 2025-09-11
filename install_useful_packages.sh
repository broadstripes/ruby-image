#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive;
apt-get update
apt-get -y --no-install-recommends install \
    curl \
    file \
    lsof \
    unzip \
    vim-tiny \
    nano \
    procps \
    less

if [[ $(. /etc/os-release; echo "$VERSION_ID") -ge 13 ]]; then
    apt-get distclean
else
    rm -rf /var/lib/apt/lists/*
fi
