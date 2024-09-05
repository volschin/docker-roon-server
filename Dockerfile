FROM debian:12.7-slim
ENV DEBIAN_FRONTEND noninteractive
ENV ROON_SERVER_PKG RoonServer_linuxx64.tar.bz2
ENV ROON_SERVER_URL https://download.roonlabs.net/builds/${ROON_SERVER_PKG}
ENV ROON_DATAROOT /data
ENV ROON_ID_DIR /data

RUN apt-get -qqy update && apt-get -qqy upgrade \
  && apt-get -qqy install --no-install-recommends --no-install-suggests ca-certificates bash curl bzip2 libicu72 cifs-utils alsa-utils procps \
  && apt-get -qqy autoremove && apt-get -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=ghcr.io/volschin/ffmpeg-static:main /download/ffmpeg /usr/bin/
VOLUME [ "/data", "/music", "/backup" ]

RUN curl -s $ROON_SERVER_URL -O \
  && tar xjf $ROON_SERVER_PKG \
  && rm -f $ROON_SERVER_PKG \
  && cat RoonServer/VERSION \
  && RoonServer/check.sh \
  && chown -R 9330:9330 /RoonServer

USER 9330:9330

LABEL org.opencontainers.image.vendor="Roon Labs LLC" \
      org.opencontainers.image.url=https://roonlabs.com \
      org.opencontainers.image.title="Roon Server" \
      org.opencontainers.image.description="Music Player & Music Server for Enthusiasts" \
      org.opencontainers.image.version=v2.0.33 \
      org.opencontainers.image.documentation=https://help.roonlabs.com/portal/en/home \
      org.opencontainers.image.authors="volschin@googlemail.com" \
      com.roon.version="2.0 (build 1455) production" \
      com.roon.release-date="2024-09-02"

# Roon documented ports
#  - multicast (discovery?)
EXPOSE 9003/udp
#  - Roon Display
EXPOSE 9100/tcp
#  - RAAT
EXPOSE 9100-9200/tcp
#  - Roon events from cloud to core (websocket?)
EXPOSE 9200/tcp
# Chromecast devices
EXPOSE 30000-30010/tcp

# See https://github.com/elgeeko1/roon-server-docker/issues/5
# https://community.roonlabs.com/t/what-are-the-new-ports-that-roon-server-needs-open-in-the-firewall/186023/16
EXPOSE 9330-9339/tcp

# ports experimentally determined; or, documented
# somewhere and source forgotten; or, commented
# in a forum without explanation. I swear I know
# what these ports do but I've run out of space
# in the margin to write the solution. Either way
# there are no other services running in the
# container that should bind to these ports,
# so exposing them shouldn't pose a security risk.
EXPOSE 9001-9002/tcp
EXPOSE 49863/tcp
EXPOSE 52667/tcp
EXPOSE 52709/tcp
EXPOSE 63098-63100/tcp

ENTRYPOINT ["/RoonServer/start.sh"]
