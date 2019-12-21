#!/usr/bin/env bash
##
# This section should match your Makefile
##
PY=${PY:-python3}

BASEDIR=$(pwd)
INPUTDIR=$BASEDIR/content
OUTPUTDIR=$BASEDIR/public

###
# Don't change stuff below here unless you are sure
###

SRV_PID=$BASEDIR/srv.pid

function usage(){
  echo "usage: $0 (stop) (start) (restart) [port]"
  echo "This starts an http server"
  exit 3
}

function alive() {
  kill -0 $1 >/dev/null 2>&1
}

function shut_down(){
  PID=$(cat $SRV_PID)
  if [[ $? -eq 0 ]]; then
    if alive $PID; then
      echo "Stopping HTTP server"
      kill $PID
    else
      echo "Stale PID, deleting"
    fi
    rm $SRV_PID
  else
    echo "HTTP server PID File not found"
  fi
}

function start_up(){
  local port=$1
  echo "Starting up HTTP server"
  shift
  cd $OUTPUTDIR
  $PY -m http.server $port &
  srv_pid=$!
  cd $BASEDIR
  echo $srv_pid > $SRV_PID
  sleep 1
  if ! alive $srv_pid ; then
    echo "The HTTP server didn't start. Is there another service using port" $port "?"
    return 1
  fi
  echo 'HTTP server processes now running in background.'
}

###
#  MAIN
###
[[ ($# -eq 0) || ($# -gt 2) ]] && usage
port=''
[[ $# -eq 2 ]] && port=$2

if [[ $1 == "stop" ]]; then
  shut_down
elif [[ $1 == "start" ]]; then
  shut_down
  start_up $port
else
  usage
fi
