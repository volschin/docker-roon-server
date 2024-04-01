FROM debian:bookworm-slim
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
      org.opencontainers.image.version=v2.0.31 \
      org.opencontainers.image.documentation=https://help.roonlabs.com/portal/en/home \
      org.opencontainers.image.authors="volschin@googlemail.com" \
      com.roon.version="2.0 (build 1388) production" \
      com.roon.release-date="2024-03-19"

ENTRYPOINT ["/RoonServer/start.sh"]
