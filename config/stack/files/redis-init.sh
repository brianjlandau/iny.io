#!/bin/sh

# Provides: redis
# Description: Startup script for redis data storage on Debian. Place in /etc/init.d and 
# run 'sudo update-rc.d redis defaults', or use the appropriate command on your
# distro.

REDISPORT=6379
EXEC=/usr/local/bin/redis-server

PIDFILE=/usr/local/var/run/redis.pid
CONF="/usr/local/etc/redis.conf"

d_start() {
   $EXEC $CONF
}

d_stop() {
   echo -n "SHUTDOWN\r\n" | nc localhost $REDISPORT &
}

case "$1" in
   start)
      if [ -f $PIDFILE ]
         then
         echo -n "$PIDFILE exists, process is already running or crashed\n"
      else
         echo -n "Starting Redis server...\n"
         d_start
         echo '.'
      fi
   ;;
   stop)
      if [ ! -f $PIDFILE ]
         then
         echo -n "$PIDFILE does not exist, process is not running\n"
      else
         PID=$(cat $PIDFILE)
         echo -n "Stopping ...\n"
         d_stop
         while [ -x /proc/${PIDFILE} ]
         do
            echo "Waiting for Redis to shutdown ..."
            sleep 1
         done
         echo "Redis stopped"
      fi
   ;;
esac

exit 0
