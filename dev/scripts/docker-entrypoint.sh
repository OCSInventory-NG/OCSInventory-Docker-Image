#!/bin/bash

# Composer install
cd /opt
php73 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php73 composer-setup.php --quiet

# Move to temp and download OCS 
cd /tmp 
git clone https://github.com/OCSInventory-NG/OCSInventory-Server OCSNG_UNIX_SERVER
cd OCSNG_UNIX_SERVER/
git clone https://github.com/OCSInventory-NG/OCSInventory-ocsreports ocsreports
cd ocsreports/
php73 /opt/composer.phar install
cd /tmp/OCSNG_UNIX_SERVER

# Create all directories
mkdir -p $OCS_WEBCONSOLE_DIR
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

# Webconsole
cp -R ocsreports/. $OCS_WEBCONSOLE_DIR

# Configure z-ocsinventory-server file 
cp /tmp/ocsinventory-server.conf /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/VERSION_MP/2/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/DATABASE_SERVER/'"$OCS_DB_SERVER"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/DATABASE_PORT/'"$OCS_DB_PORT"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/DATABASE_NAME/'"$OCS_DB_NAME"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/DATABASE_USER/'"$OCS_DB_USER"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/DATABASE_PASSWD/'"$OCS_DB_PASS"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/"PATH_TO_LOG_DIRECTORY"/'"${OCS_LOG_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/"PATH_TO_PLUGINS_PERL_DIRECTORY"/'"${OCS_PERLEXT_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/"PATH_TO_PLUGINS_CONFIG_DIRECTORY"/'"${OCS_PLUGINSEXT_DIR//\//\\/}"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/OCS_SSL_KEY/'"$OCS_SSL_KEY"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/OCS_SSL_CERT/'"$OCS_SSL_CERT"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/OCS_SSL_CA/'"$OCS_SSL_CA"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf
sed -i 's/OCS_SSL_COM_MODE/'"$OCS_SSL_COM_MODE"'/g' /etc/httpd/conf.d/z-ocsinventory-server.conf

# Configure ocsinventory-reports file 
cp /tmp/ocsinventory-reports.conf /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/OCSREPORTS_ALIAS/\/ocsreports/g' /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/PATH_TO_OCSREPORTS_DIR/'"${OCS_WEBCONSOLE_DIR//\//\\/}"'/g' /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/PACKAGES_ALIAS/\/download/g' /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/PATH_TO_PACKAGES_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'download/g' /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/SNMP_ALIAS/\/snmp/g' /etc/httpd/conf.d/ocsinventory-reports.conf
sed -i 's/PATH_TO_SNMP_DIR/'"${OCS_VARLIB_DIR//\//\\/}"'snmp/g' /etc/httpd/conf.d/ocsinventory-reports.conf

# Generate dbconfig.inc.php
cp /tmp/dbconfig.inc.php $OCS_WEBCONSOLE_DIR
sed -i 's/OCS_DB_NAME/'"$OCS_DB_NAME"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_READ_NAME/'"$OCS_DB_SERVER"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_WRITE_NAME/'"$OCS_DB_SERVER"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_DB_USER/'"$OCS_DB_USER"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_DB_PASS/'"$OCS_DB_PASS"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_SSL_ENABLED/'"$OCS_SSL_ENABLED"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/SSL_MODE/'"$OCS_SSL_WEB_MODE"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_SSL_KEY/'"$OCS_SSL_KEY"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_SSL_CERT/'"$OCS_SSL_CERT"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php
sed -i 's/OCS_SSL_CA/'"$OCS_SSL_CA"'/g' $OCS_WEBCONSOLE_DIR/dbconfig.inc.php

# Permissions
chown -R $APACHE_RUN_USER: $OCS_VARLIB_DIR
chown -R $APACHE_RUN_USER: $OCS_LOG_DIR
chown -R $APACHE_RUN_USER: $OCS_WEBCONSOLE_DIR

# Remove temp files
rm -rf /tmp/*

# Apache start
if [ ! -d "$APACHE_RUN_DIR" ]; then
	mkdir "$APACHE_RUN_DIR"
	chown $APACHE_RUN_USER:$APACHE_RUN_GROUP "$APACHE_RUN_DIR"
fi
if [ -f "$APACHE_PID_FILE" ]; then
	rm "$APACHE_PID_FILE"
fi

/usr/sbin/httpd -DFOREGROUND