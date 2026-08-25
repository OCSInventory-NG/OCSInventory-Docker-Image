#!/bin/bash

echo "+----------------------------------------------------------+"
echo "|   Setting Apache Server Name to '${APACHE_SERVER_NAME:-localhost}'"
echo "+----------------------------------------------------------+"
echo

sed -ri -e "s!^#(ServerName)\s+\S+!\1 ${APACHE_SERVER_NAME:-localhost}:80!g" \
    "/etc/apache2/apache2.conf"

# Remove temp files
echo "+--------------------------------+"
echo "|   Removing not used files...   |"
echo "+--------------------------------+"
echo
cd /tmp
shopt -s extglob
rm -rf !("conf")

# Apache start
if [ ! -d "$APACHE_RUN_DIR" ]; then
    mkdir "$APACHE_RUN_DIR"
    chown $APACHE_RUN_USER:$APACHE_RUN_GROUP "$APACHE_RUN_DIR"
fi

if [ -f "$APACHE_PID_FILE" ]; then
    rm "$APACHE_PID_FILE"
fi

echo "+----------------------------------------------------------+"
echo "|                 OK, prepare finshed ;-)                  |"
echo "|                                                          |"
echo "|      Starting OCS Inventory NG Management Docker...      |"
echo "+----------------------------------------------------------+"
echo
