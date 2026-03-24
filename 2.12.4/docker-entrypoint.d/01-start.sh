#!/bin/bash

echo "+----------------------------------------------------------+"
echo "|                                                          |"
echo "|      Welcome to OCS Inventory NG Management Docker!      |"
echo "|                                                          |"
echo "+----------------------------------------------------------+"

# Create all directories
mkdir -p $OCS_LOG_DIR
mkdir -p $OCS_PERLEXT_DIR/Apache/Ocsinventory/Plugins
mkdir -p $OCS_PLUGINSEXT_DIR
mkdir -p $OCS_VARLIB_DIR/download
mkdir -p $OCS_VARLIB_DIR/ipd
mkdir -p $OCS_VARLIB_DIR/logs
mkdir -p $OCS_VARLIB_DIR/scripts
mkdir -p $OCS_VARLIB_DIR/snmp
