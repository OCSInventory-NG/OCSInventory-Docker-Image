#!/bin/bash

API_CONF_FILE="/etc/apache2/conf-available/zz-ocsinventory-restapi.conf"
SRV_CONF_FILE="/etc/apache2/conf-available/z-ocsinventory-server.conf"
REPORTS_CONF_FILE="/etc/apache2/conf-available/ocsinventory-reports.conf"
DB_CONFIG_INC_FILE="${OCS_WEBCONSOLE_DIR}/dbconfig.inc.php"

API_ROUTE=$(perl -e "print \"@INC[2]\"")
API_ROUTE_LOADER="${API_ROUTE}/Api/Ocsinventory/Restapi/Loader.pm"

# Move to temp and download OCS 
cd /tmp 
git clone $SERVER_REPOSITORY_GIT_URL OCSNG_UNIX_SERVER -b $SERVER_REPOSITORY_BRANCH
cd OCSNG_UNIX_SERVER/
git clone $OCSREPORTS_REPOSITORY_GIT_URL ocsreports -b $OCSREPORTS_REPOSITORY_BRANCH
cd ocsreports/
composer install
cd /tmp/OCSNG_UNIX_SERVER

# Create all directories
mkdir -p ${OCS_WEBCONSOLE_DIR}
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
cd ..

cp -R Api/ $API_ROUTE

# Webconsole
cp -R ocsreports/. ${OCS_WEBCONSOLE_DIR}

# Configure z-ocsinventory-server file 
cp /tmp/ocsinventory-server.conf ${SRV_CONF_FILE}
sed -i 's/VERSION_MP/2/g' ${SRV_CONF_FILE}
sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' ${SRV_CONF_FILE}
sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' ${SRV_CONF_FILE}
sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' ${SRV_CONF_FILE}
sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' ${SRV_CONF_FILE}
sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' ${SRV_CONF_FILE}
sed -i 's/"PATH_TO_LOG_DIRECTORY"/'"${OCS_LOG_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/"PATH_TO_PLUGINS_PERL_DIRECTORY"/'"${OCS_PERLEXT_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/"PATH_TO_PLUGINS_CONFIG_DIRECTORY"/'"${OCS_PLUGINSEXT_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' ${SRV_CONF_FILE}
sed -i 's/OCS_SSL_KEY/'"${OCS_SSL_KEY//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/OCS_SSL_CERT/'"${OCS_SSL_CERT//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/OCS_SSL_CA/'"${OCS_SSL_CA//\//\\/}"'/g' ${SRV_CONF_FILE}
sed -i 's/OCS_SSL_COM_MODE/'"$OCS_SSL_COM_MODE"'/g' ${SRV_CONF_FILE}

# Configure zz-ocsinventory-restapi file
if [ ! -f ${API_CONF_FILE} ]; then
    cp /tmp/ocsinventory-restapi.conf ${API_CONF_FILE}
    sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' ${API_CONF_FILE}
    sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' ${API_CONF_FILE}
    sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' ${API_CONF_FILE}
    sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' ${API_CONF_FILE}
    sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' ${API_CONF_FILE}
    sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' ${API_CONF_FILE}
    sed -i 's/REST_API_PATH/'"${API_ROUTE//\//\\/}"'/g' ${API_CONF_FILE}
    sed -i 's/REST_API_LOADER_PATH/'"${API_ROUTE_LOADER//\//\\/}"'/g' ${API_CONF_FILE}
fi

# Configure ocsinventory-reports file 
cp /tmp/ocsinventory-reports.conf ${REPORTS_CONF_FILE}
sed -i 's/OCSREPORTS_ALIAS/\/ocsreports/g' ${REPORTS_CONF_FILE}
sed -i 's/PATH_TO_OCSREPORTS_DIR/'"${OCS_WEBCONSOLE_DIR//\//\\/}"'/g' ${REPORTS_CONF_FILE}
sed -i 's/PACKAGES_ALIAS/\/download/g' ${REPORTS_CONF_FILE}
sed -i 's/PATH_TO_PACKAGES_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'download/g' ${REPORTS_CONF_FILE}
sed -i 's/SNMP_ALIAS/\/snmp/g' ${REPORTS_CONF_FILE}
sed -i 's/PATH_TO_SNMP_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'snmp/g' ${REPORTS_CONF_FILE}

# Generate dbconfig.inc.php
cp /tmp/dbconfig.inc.php ${OCS_WEBCONSOLE_DIR}
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

# Permissions
chown -R $APACHE_RUN_USER: $OCS_VARLIB_DIR
chown -R $APACHE_RUN_USER: $OCS_LOG_DIR
chown -R $APACHE_RUN_USER: ${OCS_WEBCONSOLE_DIR}

# Enable conf
a2enconf ocsinventory-reports
a2enconf z-ocsinventory-server
a2enconf zz-ocsinventory-restapi

# Apache start
if [ ! -d "$APACHE_RUN_DIR" ]; then
	mkdir "$APACHE_RUN_DIR"
	chown $APACHE_RUN_USER:$APACHE_RUN_GROUP "$APACHE_RUN_DIR"
fi
if [ -f "$APACHE_PID_FILE" ]; then
	rm "$APACHE_PID_FILE"
fi

/usr/sbin/apache2 -DFOREGROUND
