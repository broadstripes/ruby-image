FROM docker.io/library/debian:trixie-slim
ARG RUBY_VER=2.7.8
ARG TARGETPLATFORM

RUN set -eux; \
    apt-get update; \
    apt-get -y --no-install-recommends install ca-certificates; \
    apt-get dist-clean

ENV OPENSSL_HOME=/opt/openssl/openssl-1.1.1w

RUN set -eux; \
    \
    export DEBIAN_FRONTEND=noninteractive; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
    ; \
    cd $(mktemp -d); \
    openssl_host="github.com/openssl/openssl/releases/download"; \
    openssl_file="OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz"; \
    curl -sSL "https://${openssl_host}/${openssl_file}" | tar -xz; \
    mkdir -p "$OPENSSL_HOME"; \
    cd openssl-1.1.1w; \
    if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        ARM="yes"; \
    fi; \
    ./config \
        --prefix="$OPENSSL_HOME" \
        --openssldir="$OPENSSL_HOME" \
        ${ARM:+no-afalgeng}; \
    make; \
    make test; \
    make install_sw; \
    \
    rm -rf "${OPENSSL_HOME}/certs"; \
    ln -s /etc/ssl/certs "${OPENSSL_HOME}/certs"; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /tmp/*;

# skip installing gem documentation with `gem install`/`gem update`
RUN set -eux; \
    mkdir -p /usr/local/etc; \
    echo 'gem: --no-document' >> /usr/local/etc/gemrc

ENV LANG=C.UTF-8


RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential; \
    cd $(mktemp -d); \
    ruby_i_host="github.com/postmodern/ruby-install/archive"; \
    ruby_i_ver="0.10.1"; \
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
        --with-openssl-dir="$OPENSSL_HOME"; \
    make uninstall; \
    \
    apt-get purge --yes --auto-remove build-essential; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /tmp/*; \
    \
    cd /; \
    ruby --version; \
    gem --version; \
    bundle --version

# don't create ".bundle" in all our apps
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH=$GEM_HOME/bin:$PATH
# adjust permissions of GEM_HOME for running "gem install" as an arbitrary user
RUN set -eux; \
    mkdir "$GEM_HOME"; \
    chmod 1777 "$GEM_HOME"

RUN --mount=type=bind,target=/buildcontext \
    /buildcontext/install_useful_packages.sh

COPY util/20-set-docker-prompt.sh /etc/profile.d/
