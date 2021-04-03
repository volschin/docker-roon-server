FROM debian:10-slim
ENV DEBIAN_FRONTEND noninteractive
ENV ROON_SERVER_PKG RoonServer_linuxx64.tar.bz2
ENV ROON_SERVER_URL http://download.roonlabs.com/builds/${ROON_SERVER_PKG}
ENV ROON_DATAROOT /data
ENV ROON_ID_DIR /data

RUN apt-get -q update \
  && apt-get install -qqy --no-install-recommends bash curl bzip2 ffmpeg cifs-utils alsa-utils procps \
  && apt-get autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME [ "/app", "/data", "/music", "/backup" ]

RUN curl $ROON_SERVER_URL -O \
  && tar xjf $ROON_SERVER_PKG \
  && rm -f $ROON_SERVER_PKG \
  && cat RoonServer/VERSION \
  && find /RoonServer -name "*.dll" -delete \
  && find /RoonServer -name "*.exe" -delete \
  && RoonServer/check.sh

LABEL vendor="Roon Labs LLC" \
      com.roon.version="1.8 (build 783) stable" \
      com.roon.release-date="2021-03-30"

# ENTRYPOINT /run.sh
ENTRYPOINT ["/RoonServer/start.sh"]
