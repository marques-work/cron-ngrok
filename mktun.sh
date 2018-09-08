#!/bin/bash

set -e

CONFIG_DIR="$(dirname $0)"

# These configurations can be overriden in tun.conf
# or via environment
KEEPALIVE="${KEEPALIVE:-900}" # 15 minutes
ABORT_AFTER="${ABORT_AFTER:-60}"
MONITOR_LOG="${MONITOR_LOG:-/tmp/ngrok.log}"

function now {
  /bin/date '+%Y-%m-%d %H:%M:%S'
}

function info {
  echo "[$(now)] $@"
}

function die {
  info $@ >&2
  exit 1
}

function tailpid {
  ps -eopid,command | grep "[t]ail -f $MONITOR_LOG" | awk '{print $1}'
}

function notify {
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$(now) - $@\"}" "$NOTIFY_URL"
}

function cleanup {
  if [ -n "$ngrok_pid" ]; then
    if (ps -p $ngrok_pid -opid,command | grep -q ngrok); then
      info "Bringing down ngrok at pid $ngrok_pid"
      kill -KILL $ngrok_pid
      notify "Killed tunnel."
    fi
  fi

  if [ -n "$(tailpid)" ]; then
    info "Bringing down tail"
    kill -KILL $(tailpid)
  fi
}

trap cleanup EXIT

if [ -r "$CONFIG_DIR/tun.conf" ]; then # read config
  source $CONFIG_DIR/tun.conf
fi

if [ -z "$NOTIFY_URL" ]; then
  die "NOTIFY_URL must be set!"
fi

if (which gtimeout &> /dev/null); then
  export TIMEOUT_EXEC=gtimeout
else
  if !(which timeout &> /dev/null || which gtimeout &> /dev/null); then
    die "This script requires GNU timeout"
  fi
  export TIMEOUT_EXEC=timeout
fi

if (ps -eopid,command | grep -q '[n]grok'); then
  info "ngrok is already running, exiting."
  exit 0
fi

&> $MONITOR_LOG ngrok tcp --log stdout 22 &

ngrok_pid=$!
info "ngrok pid is $ngrok_pid"

$TIMEOUT_EXEC $ABORT_AFTER tail -f $MONITOR_LOG | while read LINE; do # give 30 sec to establish a successful connection
  if [[ "${LINE}" == *"client session established"* ]]; then

    info "Tunnel connected"

    notify "Tunnel established!"

    sleep $KEEPALIVE

    info "Disconnecting tunnel after $KEEPALIVE s"
    kill -KILL $(tailpid)

    exit 0
  fi
done

notify "Failed to establish tunnel"
die "Could not establish ngrok connection"
