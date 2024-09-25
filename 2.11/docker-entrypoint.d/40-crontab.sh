#!/bin/bash

CRONTAB_FILE="/etc/cron/docker-crontab"

if [ -f $CRONTAB_FILE ]; then
    crontab $CRONTAB_FILE
    cron -n
fi