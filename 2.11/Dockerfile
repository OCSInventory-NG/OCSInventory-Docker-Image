FROM ubuntu:22.04

ENV OCS_VERSION 2.11.1

LABEL Maintainer="contact@ocsinventory-ng.org" \
      version="${OCS_VERSION}" \
      description="OCS Inventory docker image"

ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 APACHE_PID_FILE=/var/run/apache2/apache2.pid APACHE_RUN_DIR=/var/run/apache2 APACHE_LOCK_DIR=/var/lock/apache2 \
    OCS_DB_SERVER=dbsrv OCS_DB_PORT=3306 OCS_DB_USER=ocs OCS_DB_PASS=ocs OCS_DB_NAME=ocsweb \
    OCS_LOG_DIR=/var/log/ocsinventory-server OCS_VARLIB_DIR=/var/lib/ocsinventory-reports/ OCS_WEBCONSOLE_DIR=/usr/share/ocsinventory-reports \
    OCS_PERLEXT_DIR=/etc/ocsinventory-server/perl/ OCS_PLUGINSEXT_DIR=/etc/ocsinventory-server/plugins/ \
    OCS_SSL_ENABLED=0 OCS_SSL_WEB_MODE=DISABLED OCS_SSL_COM_MODE=DISABLED OCS_SSL_KEY=/path/to/key OCS_SSL_CERT=/path/to/cert OCS_SSL_CA=/path/to/ca \
    OCS_INSTALL_ENABLED=0 TZ=Europe/Paris

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    # install necessary packages
    && apt-get update && apt-get install --no-install-recommends -y \
        cron \
        nano \
        wget \
        curl \
        make \
        perl \
        build-essential \
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
        php-pclzip \
        php-mbstring \
        php-soap \
        php-mysql \
        php-curl \
        php-xml \
        php-zip \
        php-gd \
        php-ldap \
    # build perl module
    && wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/${OCS_VERSION}/OCSNG_UNIX_SERVER-${OCS_VERSION}.tar.gz -P /tmp \
    && tar xzf /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}.tar.gz -C /tmp \
    && cd /tmp/OCSNG_UNIX_SERVER-${OCS_VERSION}/Apache/ \
    && perl Makefile.PL \
    && make \
    && make install \
    # remove unnecessary packages and apt cache
    && apt-get remove -y --purge wget curl make build-essential \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* \
    # Redirect Apache2 Logs to stdout e stderr
    && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
    && ln -sf /proc/self/fd/2 /var/log/apache2/error.log


VOLUME /var/lib/ocsinventory-reports /etc/ocsinventory-server /usr/share/ocsinventory-reports/ocsreports/extensions
EXPOSE 80

COPY conf/ /tmp/conf
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

WORKDIR /etc/apache2/conf-available
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2", "-DFOREGROUND"]