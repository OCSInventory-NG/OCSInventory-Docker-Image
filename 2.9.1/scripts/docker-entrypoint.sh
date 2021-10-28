#!/bin/bash

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
	rm -rf ${OCS_WEBCONSOLE_DIR}/ocsreports/dbconfig.inc.php
fi;
    
if [ ! -z ${OCS_DISABLE_COM_MODE+x} ]; then
	echo
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_COM_MODE environment variable is set!                |"
	echo "| Communication server, which handles HTTP communications between database  |"
	echo "| server and agents (Apache, perl and mod_perl) will be DISABLED!  		  |"
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

# Configure z-ocsinventory-server file 
if [ ! -f /etc/httpd/conf.d/z-ocsinventory-server.conf ] && [ -z ${OCS_DISABLE_COM_MODE+x} ]; then
    cp /tmp/conf/ocsinventory-server.conf /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/VERSION_MP/2/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/"PATH_TO_LOG_DIRECTORY"/'"${OCS_LOG_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/"PATH_TO_PLUGINS_PERL_DIRECTORY"/'"${OCS_PERLEXT_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
	sed -i 's/"PATH_TO_PLUGINS_CONFIG_DIRECTORY"/'"${OCS_PLUGINSEXT_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
fi

# Replace Variables
SRV_CONF_FILE="/etc/httpd/conf.d/z-ocsinventory-server.conf"
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
			sed -ie "s,^\(\s*PerlSetEnv ${var^^}\).*$,\1 ${!var},g" ${SRV_CONF_FILE}
		fi
	done
fi

# Configure ocsinventory-reports file 
if [ ! -f /etc/httpd/conf.d/ocsinventory-reports.conf ] && [ -z ${OCS_DISABLE_WEB_MODE+x} ]; then
	cp /tmp/conf/ocsinventory-reports.conf /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/OCSREPORTS_ALIAS/\/ocsreports/g' /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/PATH_TO_OCSREPORTS_DIR/'"${OCS_WEBCONSOLE_DIR//\//\\/}"'\/ocsreports/g' /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/PACKAGES_ALIAS/\/download/g' /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/PATH_TO_PACKAGES_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'download/g' /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/SNMP_ALIAS/\/snmp/g' /etc/httpd/conf.d/ocsinventory-reports.conf
	sed -i 's/PATH_TO_SNMP_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'snmp/g' /etc/httpd/conf.d/ocsinventory-reports.conf
fi

# Generate dbconfig.inc.php
if [ ! -f $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php ] && [ -z ${OCS_DISABLE_WEB_MODE+x} ]; then
	cp /tmp/conf/dbconfig.inc.php $OCS_WEBCONSOLE_DIR/ocsreports
	sed -i 's/OCS_DB_NAME/'"$OCS_DB_NAME"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_READ_NAME/'"$OCS_DB_SERVER"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_WRITE_NAME/'"$OCS_DB_SERVER"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_DB_PORT/'"$OCS_DB_PORT"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_DB_USER/'"$OCS_DB_USER"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_DB_PASS/'"$OCS_DB_PASS"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_SSL_WEB_MODE/'"$OCS_SSL_WEB_MODE"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_SSL_KEY/'"${OCS_SSL_KEY//\//\\/}"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_SSL_CERT/'"${OCS_SSL_CERT//\//\\/}"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
	sed -i 's/OCS_SSL_CA/'"${OCS_SSL_CA//\//\\/}"'/g' $OCS_WEBCONSOLE_DIR/ocsreports/dbconfig.inc.php
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

/usr/sbin/httpd -DFOREGROUND
