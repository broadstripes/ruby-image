#!/usr/bin/env bash

set -euxo pipefail

apt-get -y --no-install-recommends install \
    curl \
    file \
    lsof \
    unzip \
    vim-tiny \
    nano \
    procps \
    less
