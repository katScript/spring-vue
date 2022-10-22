#!/bin/sh
### BEGIN INIT INFO
# Provides:          springboot
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       springboot api service
### END INIT INFO

SCRIPT="/usr/bin/java -jar /var/www/html/target/*.jar --server.port=8091"
DEBUG="/usr/bin/java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 /var/www/html/target/*.jar --server.port=8091"
RUNAS=root
NAME=springboot

PIDFILE=/var/run/springboot.pid
LOGFILE=/var/log/springboot.log

start() {
  if [ -f $PIDFILE ] && [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
 
  sleep 5
  PID=$(cat $PIDFILE)
    if pgrep -u $RUNAS -f $NAME > /dev/null
    then
      echo "$NAME is now running, the PID is $PID"
    else
      echo ''
      echo "Error! Could not start $NAME!"
    fi
}

debug() {
  echo 'Starting debug mode…' >&2
  local CMD="$DEBUG &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"

  sleep 5
  PID=$(cat $PIDFILE)
    if pgrep -u $RUNAS -f $NAME > /dev/null
    then
      echo "$NAME is now running, the PID is $PID"
    else
      echo ''
      echo "Error! Could not start $NAME!"
    fi
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

uninstall() {
  echo -n "Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file was not removed: $LOGFILE" >&2
    update-rc.d -f $NAME remove
    rm -fv "$0"
  else
    echo "Abort!"
  fi
}

status() {
    printf "%-50s" "Checking springboot..."
    if [ -f $PIDFILE ] && [ -s $PIDFILE ]; then
        PID=$(cat $PIDFILE)
            if [ -z "$(ps axf | grep ${PID} | grep -v grep)" ]; then
                printf "%s\n" "The process appears to be dead but pidfile still exists"
            else    
                echo "Running, the PID is $PID"
            fi
    else
        printf "%s\n" "Service not running"
    fi
}


case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  debug)
    stop
    debug
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|uninstall|debug}"
esac