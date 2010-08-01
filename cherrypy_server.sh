#!/bin/sh

PROCESSES=10
THREADS=1 # threads per process
BASE_PORT=3035 # the first port used
# you need to make the PIDFILE dir and insure it has the right permissions
PIDFILE="/var/run/django/odeon_django_cp.pid"
WORKDIR=`dirname "$0"`
cd "$WORKDIR"

cp_start_proc()
{
 N=$1
 P=$(( $BASE_PORT + $N - 1 ))
 ./manage.py runcpserver daemonize=1 port=$P pidfile="$PIDFILE-$N" threads=$THREADS request_queue_size=0
}

cp_start()
{
 for N in `seq 1 $PROCESSES`; do
  cp_start_proc $N
 done
}

cp_stop_proc()
{
 N=$1
 #[ -f "$PIDFILE-$N" ] && kill `cat "$PIDFILE-$N"`
 [ -f "$PIDFILE-$N" ] && ./manage.py runcpserver pidfile="$PIDFILE-$N" stop
 rm -f "$PIDFILE-$N"
}

cp_stop()
{
 for N in `seq 1 $PROCESSES`; do
  cp_stop_proc $N
 done
}

cp_restart_proc()
{
 N=$1
 cp_stop_proc $N
 #sleep 1
 cp_start_proc $N
}

cp_restart()
{
 for N in `seq 1 $PROCESSES`; do
  cp_restart_proc $N
 done
}

case "$1" in
 "start")
  cp_start
 ;;
 "stop")
  cp_stop
 ;;
 "restart")
  cp_restart
 ;;
 *)
  "$@"
 ;;
esac

