#!/bin/sh
set -eu

echo "+------------------------------------------------------------+"
echo "|      Starting OCS Inventory Cron Management Docker...      |"
echo "+------------------------------------------------------------+"

exec crond -n -P -x sch

# Usage:
#  crond [options]
#
# Options:
#  -h         print this message
#  -i         deamon runs without inotify support
#  -m <comm>  off, or specify prefered client for sending mails
#  -n         run in foreground
#  -p         permit any crontab
#  -P         use PATH="/usr/bin:/bin"
#  -c         enable clustering support
#  -s         log into syslog instead of sending mails
#  -x <flag>  print debug information
#
# Debugging flags are: ext,sch,proc,pars,load,misc,test,bit
