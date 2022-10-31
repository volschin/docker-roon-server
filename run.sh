#!/bin/bash
cd /app
if test ! -d RoonServer; then
  curl -L $ROON_SERVER_URL -O
  tar xjf $ROON_SERVER_PKG
  rm -f $ROON_SERVER_PKG
fi
/usr/sbin/alsactl restore
exec /app/RoonServer/start.sh
