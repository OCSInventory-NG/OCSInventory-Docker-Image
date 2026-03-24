#!/bin/bash

VAR_FILE=${OCS_WEBCONSOLE_DIR}/ocsreports/var.php

if [ -f ${VAR_FILE} ]; then
    echo "+-----------------------------------------------+"
	echo "|   Customizing OCS Console AUTHTYPE...         |"
	echo "+-----------------------------------------------+"
	echo
    sed -ri -e "/AUTH_TYPE/c\define('AUTH_TYPE', $AUTH_TYPE);" ${VAR_FILE}
fi