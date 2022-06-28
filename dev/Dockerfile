FROM ubuntu:22.04

LABEL maintainer="contact@ocsinventory-ng.org" \
      version="dev" \
      description="OCS Inventory docker image"

ARG APT_FLAGS="-y"

ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_DIR=/var/run/apache2 APACHE_LOCK_DIR=/var/lock/apache2 \
    OCS_DB_SERVER=dbsrv OCS_DB_PORT=3306 OCS_DB_USER=ocs OCS_DB_PASS=ocs OCS_DB_NAME=ocsweb \
    OCS_LOG_DIR=/var/log/ocsinventory-server OCS_VARLIB_DIR=/var/lib/ocsinventory-reports/ OCS_WEBCONSOLE_DIR=/usr/share/ocsinventory-reports/ocsreports/ \
    OCS_PERLEXT_DIR=/etc/ocsinventory-server/perl/ OCS_PLUGINSEXT_DIR=/etc/ocsinventory-server/plugins/ \
    OCS_SSL_ENABLED=0 OCS_SSL_WEB_MODE=DISABLED OCS_SSL_COM_MODE=DISABLED OCS_SSL_KEY=/path/to/key OCS_SSL_CERT=/path/to/cert OCS_SSL_CA=/path/to/ca \
    SERVER_REPOSITORY_GIT_URL=https://github.com/OCSInventory-NG/OCSInventory-Server SERVER_REPOSITORY_BRANCH=master \
    OCSREPORTS_REPOSITORY_GIT_URL=https://github.com/OCSInventory-NG/OCSInventory-ocsreports OCSREPORTS_REPOSITORY_BRANCH=master \
    TZ=Europe/Paris

WORKDIR /tmp

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

VOLUME /var/lib/ocsinventory-reports /etc/ocsinventory-server /usr/share/ocsinventory-reports/ocsreports

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    make \
    perl \
    apache2 \
    php \
    libxml-simple-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libapache-dbi-perl \
    libnet-ip-perl \
    libsoap-lite-perl \
    libarchive-zip-perl \
    libswitch-perl \
    libmojolicious-perl \
    libplack-perl \
    build-essential \
    php-pclzip \
    php-mbstring \
    php-soap \
    php-mysql \
    php-curl \
    php-xml \
    php-zip \
    php-gd \
    git \
    vim \
    nano \
    composer \
    php-ldap

COPY conf/* /tmp/conf/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
