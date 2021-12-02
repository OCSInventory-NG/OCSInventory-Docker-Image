#!/bin/bash

API_CONF_FILE="/etc/httpd/conf.d/zz-ocsinventory-restapi.conf"
SRV_CONF_FILE="/etc/httpd/conf.d/z-ocsinventory-server.conf"
REPORTS_CONF_FILE="/etc/httpd/conf.d/ocsinventory-reports.conf"
DB_CONFIG_INC_FILE="${OCS_WEBCONSOLE_DIR}/ocsreports/dbconfig.inc.php"

echo
echo "+----------------------------------------------------------+"
echo "|                                                          |"
echo "|      Welcome to OCS Inventory NG Management Docker!      |"
echo "|                                                          |"
echo "+----------------------------------------------------------+"
echo

# Create all directories
mkdir -p $OCS_LOG_DIR
mkdir -p $OCS_PERLEXT_DIR/Apache/Ocsinventory/Plugins
mkdir -p $OCS_PLUGINSEXT_DIR
mkdir -p $OCS_VARLIB_DIR/download
mkdir -p $OCS_VARLIB_DIR/ipd
mkdir -p $OCS_VARLIB_DIR/logs
mkdir -p $OCS_VARLIB_DIR/scripts
mkdir -p $OCS_VARLIB_DIR/snmp

if [ ! -f $OCS_WEBCONSOLE_DIR/ocsreports/var.php ]; then
	cp -r /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/ocsreports/ ${OCS_WEBCONSOLE_DIR}
	rm -rf ${DB_CONFIG_INC_FILE}
fi;

cp -r /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/Api/ /usr/local/share/perl5

if [ ! -z ${OCS_DISABLE_API_MODE+x} ]; then
	echo
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_API_MODE environment variable is set!                |"
	echo "| REST API will be DISABLED                                                 |"
	echo "+---------------------------------------------------------------------------+"
	echo
fi 

if [ ! -z ${OCS_DISABLE_COM_MODE+x} ]; then
	echo
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_COM_MODE environment variable is set!                |"
	echo "| Communication server, which handles HTTP communications between database  |"
	echo "| server and agents (Apache, perl and mod_perl) will be DISABLED!  	  |"
	echo "+---------------------------------------------------------------------------+"
	echo
fi

if [ ! -z ${OCS_DISABLE_WEB_MODE+x} ]; then
	echo
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_WEB_MODE environment variable is set!                |"
	echo "| Administration console, which allows administrators to query the database |"
	echo "| server using their favorite browser (Apache, php) will be DISABLED!  	  |"
	echo "+---------------------------------------------------------------------------+"
	echo
fi

echo "+----------------------------------------------------------+"
echo "|   Setting Apache Server Name to '${APACHE_SERVER_NAME:-localhost}'"
echo "+----------------------------------------------------------+"
echo
sed -ri -e "s!^#(ServerName)\s+\S+!\1 ${APACHE_SERVER_NAME:-localhost}:80!g" \
      "/etc/httpd/conf/httpd.conf"

# Configure z-ocsinventory-server file 
if [ ! -f ${SRV_CONF_FILE} ] && [ -z ${OCS_DISABLE_COM_MODE+x} ]; then
    cp /tmp/conf/ocsinventory-server.conf ${SRV_CONF_FILE}
	sed -i 's/VERSION_MP/2/g' ${SRV_CONF_FILE}
	sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' ${SRV_CONF_FILE}
	sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' ${SRV_CONF_FILE}
	sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' ${SRV_CONF_FILE}
	sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' ${SRV_CONF_FILE}
	sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' ${SRV_CONF_FILE}
	sed -i 's/"PATH_TO_LOG_DIRECTORY"/'"${OCS_LOG_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
	sed -i 's/"PATH_TO_PLUGINS_PERL_DIRECTORY"/'"${OCS_PERLEXT_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
	sed -i 's/"PATH_TO_PLUGINS_CONFIG_DIRECTORY"/'"${OCS_PLUGINSEXT_DIR//\//\\/}"'/g' ${SRV_CONF_FILE}
fi

# Configure zz-ocsinventory-restapi file
if [ ! -f ${API_CONF_FILE} ] && [ -z ${OCS_DISABLE_API_MODE+x} ]; then
    cp /tmp/conf/ocsinventory-restapi.conf ${API_CONF_FILE}
       sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' ${API_CONF_FILE}
       sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' ${API_CONF_FILE}
       sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' ${API_CONF_FILE}
       sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' ${API_CONF_FILE}
       sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' ${API_CONF_FILE}
       sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' ${API_CONF_FILE}
       sed -i 's/REST_API_PATH/\/usr\/local\/share\/perl5/g' ${API_CONF_FILE}
       sed -i 's/REST_API_LOADER_PATH/\/usr\/local\/share\/perl5\/Api\/Ocsinventory\/Restapi\/Loader.pm/g' ${API_CONF_FILE}
fi

# Replace Variables
if [ -f ${SRV_CONF_FILE} ] && [ -z ${OCS_DISABLE_COM_MODE+x} ]; then
	echo "+-----------------------------------------------+"
	echo "|   Customizing from environment variables...   |"
	echo "+-----------------------------------------------+"
	echo
	# Get all env vars starting with 'OCS_'
	for var in $(env | cut -f1 -d= | grep -i OCS_); do
		# Check that the current var is not commented out in conf file
		if grep -q "^\s*PerlSetEnv ${var^^}" ${SRV_CONF_FILE} ; then
			echo "Applying Config ${var^^}=${!var} from environment variable"
			sed -i "s,^\(\s*PerlSetEnv ${var^^}\).*$,\1 ${!var},g" ${SRV_CONF_FILE}
		fi
	done
fi

# Configure ocsinventory-reports file 
if [ ! -f ${REPORTS_CONF_FILE} ] && [ -z ${OCS_DISABLE_WEB_MODE+x} ]; then
	cp /tmp/conf/ocsinventory-reports.conf ${REPORTS_CONF_FILE}
	sed -i 's/OCSREPORTS_ALIAS/\/ocsreports/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_OCSREPORTS_DIR/'"${OCS_WEBCONSOLE_DIR//\//\\/}"'\/ocsreports/g' ${REPORTS_CONF_FILE}
	sed -i 's/PACKAGES_ALIAS/\/download/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_PACKAGES_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'download/g' ${REPORTS_CONF_FILE}
	sed -i 's/SNMP_ALIAS/\/snmp/g' ${REPORTS_CONF_FILE}
	sed -i 's/PATH_TO_SNMP_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'snmp/g' ${REPORTS_CONF_FILE}
fi

# Generate dbconfig.inc.php
if [ ! -f ${DB_CONFIG_INC_FILE} ] && [ -z ${OCS_DISABLE_WEB_MODE+x} ]; then
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
chown -R $APACHE_RUN_USER: $OCS_LOG_DIR
chown -R $APACHE_RUN_USER: $OCS_WEBCONSOLE_DIR

# rm install.php
if [ -f $OCS_WEBCONSOLE_DIR/ocsreports/install.php ]; then
	rm $OCS_WEBCONSOLE_DIR/ocsreports/install.php
fi

# Remove temp files
echo
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

exec "$@"