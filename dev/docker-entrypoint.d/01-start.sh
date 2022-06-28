#!/bin/bash

echo "+----------------------------------------------------------+"
echo "|                                                          |"
echo "|      Welcome to OCS Inventory NG Management Docker!      |"
echo "|                                                          |"
echo "+----------------------------------------------------------+"

# Move to temp and download OCS 
cd /tmp 
git clone $SERVER_REPOSITORY_GIT_URL OCSNG_UNIX_SERVER -b $SERVER_REPOSITORY_BRANCH
cd OCSNG_UNIX_SERVER/
git clone $OCSREPORTS_REPOSITORY_GIT_URL ocsreports -b $OCSREPORTS_REPOSITORY_BRANCH
cd ocsreports/
composer install
cd /tmp/OCSNG_UNIX_SERVER

# Create all directories
mkdir -p $OCS_LOG_DIR
mkdir -p $OCS_PERLEXT_DIR/Apache/Ocsinventory/Plugins
mkdir -p $OCS_PLUGINSEXT_DIR
mkdir -p $OCS_VARLIB_DIR/download
mkdir -p $OCS_VARLIB_DIR/ipd
mkdir -p $OCS_VARLIB_DIR/logs
mkdir -p $OCS_VARLIB_DIR/scripts
mkdir -p $OCS_VARLIB_DIR/snmp

# Server compilation
cd Apache
perl Makefile.PL
make
make install