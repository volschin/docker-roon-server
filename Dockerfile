FROM debian:bookworm-slim AS ffmpeg
ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /download/
RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends xz-utils \
  && cd /download \
  && tar -xvf ffmpeg-release-amd64-static.tar.xz ffmpeg \
  && ls -la
  && ./ffmpeg

FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND noninteractive
ENV ROON_SERVER_PKG RoonServer_linuxx64.tar.bz2
ENV ROON_SERVER_URL https://download.roonlabs.net/builds/${ROON_SERVER_PKG}
ENV ROON_DATAROOT /data
ENV ROON_ID_DIR /data

RUN apt -qqy update && apt -qqy upgrade \
  && apt -qqy install --no-install-recommends --no-install-suggests ca-certificates bash curl bzip2 libicu72 cifs-utils alsa-utils procps \
  && apt -qqy autoremove && apt -qqy clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=ffmpeg /ffmpeg /ffmpeg
VOLUME [ "/data", "/music", "/backup" ]

RUN ls -la /ffmpeg \
  && curl -s $ROON_SERVER_URL -O \
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
