#!/bin/bash
set -eux

RUN_FLUXBOX=${RUN_FLUXBOX:-yes}
RUN_XTERM=${RUN_XTERM:-yes}
RUN_SRCDS=${RUN_SRCDS:-yes}

case $RUN_FLUXBOX in
  false|no|n|0)
    rm -f /app/conf.d/fluxbox.conf
    ;;
esac

case $RUN_XTERM in
  false|no|n|0)
    rm -f /app/conf.d/xterm.conf
    ;;
esac

case $RUN_SRCDS in
  false|no|n|0)
    rm -f /app/conf.d/srcds.conf
    ;;
esac

exec supervisord -c /app/supervisord.conf