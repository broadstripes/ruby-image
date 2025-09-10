FROM debian:bullseye-slim
ENV RUBY_VER=2.6.8

# Generally useful packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y --no-install-recommends install \
    ca-certificates \
    curl \
    file \
    lsof \
    gpg \
    gpg-agent \
    unzip \
    vim-tiny \
    nano \
    procps \
    less

# Install OpenSSL and Ruby
# TODO: remove OpenSSL 1 after upgrading to ruby 3.1
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get -y --no-install-recommends install build-essential; \
    cd $(mktemp -d); \
    openssl_host="github.com/openssl/openssl/releases/download"; \
    openssl_file="OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz"; \
    curl -sSL "https://${openssl_host}/${openssl_file}" | tar -xz; \
    openssl_home="/opt/openssl/openssl-1.1.1w"; \
    mkdir -p "$openssl_home"; \
    cd openssl-1.1.1w; \
    if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        ARM="yes"; \
    fi; \
    ./config \
        --prefix="$openssl_home" \
        --openssldir="$openssl_home" \
        ${ARM:+no-afalgeng}; \
    make; \
    make test; \
    make install_sw; \
    rm -rf "${openssl_home}/certs"; \
    ln -s /etc/ssl/certs "${openssl_home}/certs"; \
    cd $(mktemp -d); \
    ruby_i_host="github.com/postmodern/ruby-install/archive"; \
    ruby_i_ver="0.9.3"; \
    curl -sSL "https://${ruby_i_host}/v${ruby_i_ver}.tar.gz" | tar -xz; \
    cd "ruby-install-$ruby_i_ver"; \
    make install; \
    ruby-install \
        --cleanup \
        --system \
        "$RUBY_VER" \
        -- \
        --disable-install-rdoc \
        --disable-install-doc \
        --enable-shared \
        --with-openssl-dir="$openssl_home"; \
    make uninstall; \
    apt-get purge --yes --auto-remove build-essential; \
    rm -rf /root/.cache; \
    rm -rf /tmp/*;

COPY 20-set-docker-prompt.sh /etc/profile.d/
