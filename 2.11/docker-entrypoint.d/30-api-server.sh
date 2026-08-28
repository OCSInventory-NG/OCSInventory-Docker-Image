#!/bin/bash

if [ ! -z "${OCS_DISABLE_API_MODE}" ] || [ ! -z "${OCS_DISABLE_COM_MODE}" ]; then
	echo "+---------------------------------------------------------------------------+"
	echo "| Warning: OCS_DISABLE_API_MODE or OCS_DISABLE_COM_MODE environment         |"
	echo "| variable is set!                                                          |"
	echo "| REST API will be DISABLED                                                 |"
	echo "+---------------------------------------------------------------------------+"
	exit 0
fi

export API_CONF_FILE="/etc/apache2/conf-available/zz-ocsinventory-restapi.conf"
export API_ROUTE=$(perl -e "print \"@INC[2]\"")
export API_ROUTE_LOADER="${API_ROUTE}/Api/Ocsinventory/Restapi/Loader.pm"

cp -R /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/Api/ ${API_ROUTE}

# Configure zz-ocsinventory-restapi file
if [ ! -f ${API_CONF_FILE} ]; then
	cp /tmp/conf/ocsinventory-restapi.conf ${API_CONF_FILE}
	perl -i -p -e 's/DATABASE_SERVER/$ENV{OCS_DB_SERVER}/g' ${API_CONF_FILE}
	perl -i -p -e 's/DATABASE_PORT/$ENV{OCS_DB_PORT}/g' ${API_CONF_FILE}
	perl -i -p -e 's/DATABASE_NAME/$ENV{OCS_DB_NAME}/g' ${API_CONF_FILE}
	perl -i -p -e 's/DATABASE_USER/$ENV{OCS_DB_USER}/g' ${API_CONF_FILE}
	perl -i -p -e 's/DATABASE_PASSWD/$ENV{OCS_DB_PASS}/g' ${API_CONF_FILE}
	perl -i -p -e 's/OCS_SSL_ENABLED/$ENV{OCS_SSL_ENABLED}/g' ${API_CONF_FILE}
	perl -i -p -e 's/REST_API_PATH/$ENV{API_ROUTE}/g' ${API_CONF_FILE}
	perl -i -p -e 's/REST_API_LOADER_PATH/$ENV{API_ROUTE_LOADER}/g' ${API_CONF_FILE}
fi

# Enable conf
a2enconf zz-ocsinventory-restapi