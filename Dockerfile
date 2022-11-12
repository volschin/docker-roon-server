FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND noninteractive
ENV ROON_SERVER_PKG RoonServer_linuxx64.tar.bz2
ENV ROON_SERVER_URL http://download.roonlabs.net/builds/${ROON_SERVER_PKG}
ENV ROON_DATAROOT /data
ENV ROON_ID_DIR /data

RUN apt-get -q update && apt-get -qq install eatmydata\
  && eatmydata apt-get -qq upgrade && eatmydata apt-get install -qqy --no-install-recommends bash curl bzip2 ffmpeg cifs-utils alsa-utils procps \
  && eatmydata apt-get autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME [ "/data", "/music", "/backup" ]

ENV LD_PRELOAD libeatmydata.so
RUN curl -s $ROON_SERVER_URL -O \
  && tar xjf $ROON_SERVER_PKG \
  && rm -f $ROON_SERVER_PKG \
  && cat RoonServer/VERSION \
#  && find /RoonServer -name "*.dll" -delete \
#  && find /RoonServer -name "*.exe" -delete \
  && RoonServer/check.sh

LABEL org.opencontainers.image.vendor="Roon Labs LLC" \
      org.opencontainers.image.url=https://roonlabs.com \
      org.opencontainers.image.title="Roon Server" \
      org.opencontainers.image.description="Music Player & Music Server for Enthusiasts" \
      org.opencontainers.image.version=v2.0.1 \
      org.opencontainers.image.documentation=https://help.roonlabs.com/portal/en/home \
      com.roon.version="2.0 (build 1133) stable" \
      com.roon.release-date="2022-10-10"

# ENTRYPOINT /run.sh
ENTRYPOINT ["/RoonServer/start.sh"]
