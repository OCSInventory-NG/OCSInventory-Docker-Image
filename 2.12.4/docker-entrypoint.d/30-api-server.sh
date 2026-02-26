#!/bin/bash

if [ ! -z "${OCS_DISABLE_API_MODE}" ] || [ ! -z "${OCS_DISABLE_COM_MODE}" ]; then
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_API_MODE or OCS_DISABLE_COM_MODE environment         |"
	echo "| variable is set!                                                          |"
	echo "| REST API will be DISABLED                                                 |"
	echo "+---------------------------------------------------------------------------+"
	exit 0
fi

API_CONF_FILE="/etc/apache2/conf-available/zz-ocsinventory-restapi.conf"
API_ROUTE=$(perl -e "print \"@INC[2]\"")
API_ROUTE_LOADER="${API_ROUTE}/Api/Ocsinventory/Restapi/Loader.pm"

cp -R /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/Api/ ${API_ROUTE}

# Configure zz-ocsinventory-restapi file
if [ ! -f ${API_CONF_FILE} ]; then
	cp /tmp/conf/ocsinventory-restapi.conf ${API_CONF_FILE}
	sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' ${API_CONF_FILE}
	sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' ${API_CONF_FILE}
	sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' ${API_CONF_FILE}
	sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' ${API_CONF_FILE}
	sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' ${API_CONF_FILE}
	sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' ${API_CONF_FILE}
	sed -i 's/REST_API_PATH/'"${API_ROUTE//\//\\/}"'/g' ${API_CONF_FILE}
	sed -i 's/REST_API_LOADER_PATH/'"${API_ROUTE_LOADER//\//\\/}"'/g' ${API_CONF_FILE}
fi

# Enable conf
a2enconf zz-ocsinventory-restapi
