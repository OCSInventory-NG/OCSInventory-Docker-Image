#!/bin/bash

REPORTS_CONF_FILE="/etc/apache2/conf-available/ocsinventory-reports.conf"
DB_CONFIG_INC_FILE="${OCS_WEBCONSOLE_DIR}/ocsreports/dbconfig.inc.php"

if [ ! -z "${OCS_DISABLE_WEB_MODE}" ]; then
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_WEB_MODE environment variable is set!                |"
	echo "| Administration console, which allows administrators to query the database |"
	echo "| server using their favorite browser (Apache, php) will be DISABLED!       |"
	echo "+---------------------------------------------------------------------------+"
	exit 0
fi

if [ ! -f $OCS_WEBCONSOLE_DIR/ocsreports/var.php ]; then
	cp -r /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/ocsreports/ ${OCS_WEBCONSOLE_DIR}
	rm -rf ${DB_CONFIG_INC_FILE}
fi

# Configure ocsinventory-reports file
if [ ! -f ${REPORTS_CONF_FILE} ]; then
	cp /tmp/conf/ocsinventory-reports.conf ${REPORTS_CONF_FILE}
	sed -i 's/OCSREPORTS_ALIAS/\/ocsreports/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_OCSREPORTS_DIR/'"${OCS_WEBCONSOLE_DIR//\//\\/}"'\/ocsreports/g' ${REPORTS_CONF_FILE}
	sed -i 's/PACKAGES_ALIAS/\/download/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_PACKAGES_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'download/g' ${REPORTS_CONF_FILE}
	sed -i 's/SNMP_ALIAS/\/snmp/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_SNMP_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'snmp/g' ${REPORTS_CONF_FILE}
fi

# Generate dbconfig.inc.php
if [ ! -f ${DB_CONFIG_INC_FILE} ]; then
	cp /tmp/conf/dbconfig.inc.php $OCS_WEBCONSOLE_DIR/ocsreports
	sed -i 's/OCS_DB_NAME/'"$OCS_DB_NAME"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_READ_NAME/'"$OCS_DB_SERVER"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_WRITE_NAME/'"$OCS_DB_SERVER"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_DB_PORT/'"$OCS_DB_PORT"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_DB_USER/'"$OCS_DB_USER"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_DB_PASS/'"$OCS_DB_PASS"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_SSL_WEB_MODE/'"$OCS_SSL_WEB_MODE"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_SSL_KEY/'"${OCS_SSL_KEY//\//\\/}"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_SSL_CERT/'"${OCS_SSL_CERT//\//\\/}"'/g' ${DB_CONFIG_INC_FILE}
	sed -i 's/OCS_SSL_CA/'"${OCS_SSL_CA//\//\\/}"'/g' ${DB_CONFIG_INC_FILE}
fi

# Permissions
chown -R $APACHE_RUN_USER: $OCS_VARLIB_DIR
chown -R $APACHE_RUN_USER: $OCS_WEBCONSOLE_DIR

# rm install.php
if [ -f $OCS_WEBCONSOLE_DIR/ocsreports/install.php ]; then
	rm $OCS_WEBCONSOLE_DIR/ocsreports/install.php
fi

# Enable conf
a2enconf ocsinventory-reports
