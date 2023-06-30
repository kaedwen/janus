FROM alpine as builder

RUN apk update && apk add --no-cache \
  build-base \
  git \
  cmake \
  jansson-dev \
  libconfig-dev \
  libnice-dev \
  openssl-dev \
  libsrtp-dev \
  libwebsockets-dev \
  zlib-dev \
  opus \
  glib \
  autoconf \
  automake \
  libtool \
  pkgconfig

WORKDIR /build
RUN git clone https://github.com/meetecho/janus-gateway.git .
RUN sh autogen.sh && ./configure --prefix=/ && make && DESTDIR=/janus make install

FROM alpine

RUN apk update && apk add --no-cache \
  jansson \
  libnice \
  openssl \
  libsrtp \
  libconfig \
  libwebsockets \
  zlib \
  opus \
  glib

COPY --from=builder /janus /

WORKDIR /etc/janus
RUN mv janus.jcfg.sample janus.jcfg
RUN mv janus.plugin.videoroom.jcfg.sample janus.plugin.videoroom.jcfg
RUN mv janus.transport.websockets.jcfg.sample janus.transport.websockets.jcfg

WORKDIR /

CMD ["/bin/janus"]