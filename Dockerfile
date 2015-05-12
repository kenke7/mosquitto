FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/var/lib/mosquitto", "/etc/mosquitto"]

RUN buildDeps='wget build-essential cmake bzip2 mercurial git libwrap0-dev libssl-dev libc-ares-dev xsltproc docbook docbook-xsl uuid-dev zlib1g-dev'; \
  mkdir -p /var/lib/mosquitto && \
  touch /var/lib/mosquitto/.keep && \
  apt-get update -q && \
  apt-get install -qy $buildDeps openssl --no-install-recommends && \
  wget -O - http://git.warmcat.com/cgi-bin/cgit/libwebsockets/snapshot/libwebsockets-1.4-chrome43-firefox-36.tar.gz  | tar -zxvf - && \
  cd libwebsockets-1.4-chrome43-firefox-36/ && \
  mkdir build && \
  cd build && \
  cmake .. -DLWS_WITH_HTTP2=1 -DLWS_WITHOUT_TESTAPPS=1 && \
  make && \
  make install && \
  ldconfig -v && \
  cd / && rm -rf libwebsockets-1.4-chrome43-firefox-36/ && \
  git clone git://git.eclipse.org/gitroot/mosquitto/org.eclipse.mosquitto.git && \
  cd org.eclipse.mosquitto && \
  sed -i "s/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/" config.mk && \
  make && \
  make install && \
  cd / && rm -rf org.eclipse.mosquitto && \
  apt-get purge -y --auto-remove $buildDeps

RUN groupadd -r mosquitto && \
  useradd -r -g mosquitto mosquitto

CMD ["mosquitto", "-c", "/etc/mosquitto/mosquitto.conf"]