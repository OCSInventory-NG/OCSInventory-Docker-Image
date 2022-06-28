#!/bin/bash

SRV_CONF_FILE="/etc/apache2/conf-available/z-ocsinventory-server.conf"

if [ ! -z "${OCS_DISABLE_COM_MODE}" ]; then
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_COM_MODE environment variable is set!                |"
	echo "| Communication server, which handles HTTP communications between database  |"
	echo "| server and agents (Apache, perl and mod_perl) will be DISABLED!           |"
	echo "+---------------------------------------------------------------------------+"
	exit 0
fi

# Configure z-ocsinventory-server file
if [ ! -f ${SRV_CONF_FILE} ]; then
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

# Replace Variables
if [ -f ${SRV_CONF_FILE} ]; then
	echo "+-----------------------------------------------+"
	echo "|   Customizing from environment variables...   |"
	echo "+-----------------------------------------------+"
	echo
	# Get all env vars starting with 'OCS_'
	for var in $(env | cut -f1 -d= | grep -i OCS_); do
		# Check that the current var is not commented out in conf file
		if grep -q "^\s*PerlSetEnv ${var^^}" ${SRV_CONF_FILE}; then
			echo "Applying Config ${var^^}=${!var} from environment variable"
			sed -i "s,^\(\s*PerlSetEnv ${var^^}\).*$,\1 ${!var},g" ${SRV_CONF_FILE}
		fi
	done
fi

# Permissions
chown -R $APACHE_RUN_USER: $OCS_LOG_DIR

# Enable conf
a2enconf z-ocsinventory-server
