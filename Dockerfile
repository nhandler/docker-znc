FROM debian:stable
MAINTAINER Nathan Handler <nathan.handler@gmail.com>

ENV ZNC_VERSION 1.6.6
ONBUILD ENV DEBIAN_FRONTEND=non_interactive

RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    build-essential \
    git \
    libcurl4-openssl-dev \
    libicu-dev \
    libjson-perl \
    libperl-dev \
    libsasl2-dev \
    libssl-dev \
    patch \
    pkg-config \
    python3-dev \
    python3-requests \
    sudo \
    swig3.0 \
    tcl \
    tcl-dev \
    wget
RUN mkdir -p /src
RUN cd /src && git clone https://github.com/znc/znc.git
RUN cd "/src/znc" \
    && git checkout "tags/znc-${ZNC_VERSION}" \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --enable-perl --enable-python --enable-tcl --enable-cyrus \
    && (make || make) \
    && make install
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /src* /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd znc
ADD docker-entrypoint.sh /entrypoint.sh
ADD znc.conf.default /znc.conf.default
RUN chmod 644 /znc.conf.default

VOLUME /znc-data

EXPOSE 6667
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]

# vim: tabstop=4 expandtab fenc=utf-8
