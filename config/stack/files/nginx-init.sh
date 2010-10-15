#! /bin/sh

# Provides: nginx
# Description: Startup script for nginx webserver on Debian. Place in /etc/init.d and 
# run 'sudo update-rc.d nginx defaults', or use the appropriate command on your
# distro.
#
# Author:	Ryan Norbauer <ryan.norbauer@gmail.com>
# Modified:     Geoffrey Grosenbach http://topfunky.com

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="nginx daemon"
NAME=nginx
DAEMON=/usr/local/nginx/sbin/$NAME
CONFIGFILE=/usr/local/nginx/conf/nginx.conf
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

d_start() {
  $DAEMON -c $CONFIGFILE || echo -n " already running"
}

d_stop() {
  kill -QUIT `cat $PIDFILE` || echo -n " not running"
}

d_reload() {
  kill -HUP `cat $PIDFILE` || echo -n " can't reload"
}

case "$1" in
  start)
  	echo -n "Starting $DESC: $NAME"
  	d_start
  	echo "."
	;;
  stop)
  	echo -n "Stopping $DESC: $NAME"
  	d_stop
  	echo "."
	;;
  reload)
  	echo -n "Reloading $DESC configuration..."
  	d_reload
  	echo "reloaded."
  ;;
  restart)
  	echo -n "Restarting $DESC: $NAME"
  	d_stop
  	# One second might not be time enough for a daemon to stop, 
  	# if this happens, d_start will fail (and dpkg will break if 
  	# the package is being upgraded). Change the timeout if needed
  	# be, or change d_stop to have start-stop-daemon use --retry. 
  	# Notice that using --retry slows down the shutdown process somewhat.
  	sleep 1
  	d_start
  	echo "."
	;;
  *)
	  echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
	  exit 3
	;;
esac

exit 0
