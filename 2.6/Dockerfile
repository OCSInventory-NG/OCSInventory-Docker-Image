FROM centos:centos7

LABEL maintainer="contact@ocsinventory-ng.org" \
      version="2.6" \
      description="OCS Inventory docker image"

ARG YUM_FLAGS="-y"

VOLUME /var/lib/ocsinventory-reports /usr/share/ocsinventory-reports/ocsreports/extensions /etc/ocsinventory-server /etc/httpd/conf.d

ENV APACHE_RUN_USER=apache APACHE_RUN_GROUP=apache \
    APACHE_LOG_DIR=/var/log/httpd APACHE_PID_FILE=/var/run/httpd.pid APACHE_RUN_DIR=/var/run/httpd APACHE_LOCK_DIR=/var/lock/httpd \
    OCS_DB_SERVER=ocsdb OCS_DB_PORT=3306 OCS_DB_USER=ocs OCS_DB_PASS=ocs OCS_DB_NAME=ocsweb \
    OCS_LOG_DIR=/var/log/ocsinventory-server/ OCS_VARLIB_DIR=/var/lib/ocsinventory-reports/ OCS_WEBCONSOLE_DIR=/usr/share/ocsinventory-reports/ocsreports/ \
    OCS_PERLEXT_DIR=/etc/ocsinventory-server/perl/ OCS_PLUGINSEXT_DIR=/etc/ocsinventory-server/plugins/ \
    TZ=Europe/Paris

WORKDIR /tmp

RUN yum ${YUM_FLAGS} install wget \
    curl \
    yum-utils \
    tar \
    make \
    yum ${YUM_FLAGS} install epel-release ; \
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm ; \
    wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm ; \
    rpm -Uvh remi-release-7.rpm ; \
    yum-config-manager --enable remi-php73 ; \
    yum ${YUM_FLAGS} update ; \
    yum ${YUM_FLAGS} install perl \
    perl-XML-Simple \
    perl-Compress-Zlib \
    perl-DBI perl-DBD-MySQL \
    perl-Net-IP \
    perl-SOAP-Lite \
    perl-Archive-Zip \
    perl-Mojolicious \
    perl-Plack \
    perl-XML-Entities \
    perl-Switch \
    perl-Apache-DBI \
    httpd \
    php73-php \
    php73-php-cli \
    php73-php-cli \
    php73-php-gd \
    php73-php-imap \
    php73-php-pdo \
    php73-php-pear \
    php73-php-mbstring \
    php73-php-intl \
    php73-php-mysqlnd \
    php73-php-xml \
    php73-php-xmlrpc \
    php73-php-pecl-mysql \
    php73-php-pecl-mcrypt \
    php73-php-pecl-apcu \
    php73-php-json \
    php73-php-soap \
    php73-php-fpm \
    php73-php-opcache ;

COPY conf/ /tmp/conf
COPY ./scripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
