FROM debian:stretch-slim

LABEL maintainer="contact@ocsinventory-ng.org"
LABEL version="2.5"
LABEL description="OCS (Open Computers and Software Inventory Next Generation)"

ARG APT_FLAGS="-y --no-install-recommends"

VOLUME /var/lib/mysql

RUN apt-get update ; \
    apt-get ${APT_FLAGS} install \
    apache2 \
    apache2-doc \
    apt-utils \
    php7.0 \
    php7.0-gd \
    php7.0-mysql \
    php7.0-cgi \
    php7.0-curl \
    php7.0-xml \
    php7.0-soap \
    php7.0-zip \
    perl \
    build-essential \
    libapache2-mod-php7.0 \
    libxml2 \
    libxml-simple-perl \
    libc6-dev \
    libnet-ip-perl \
    libxml-libxml-perl \
    libapache2-mod-perl2 \
    libdbi-perl \
    libapache-dbi-perl \
    libdbd-mysql-perl \
    libio-compress-perl \
    libxml-simple-perl \
    libsoap-lite-perl \
    libarchive-zip-perl \
    libnet-ip-perl \
    php-mbstring \
    php-pclzip \
    libsoap-lite-perl \
    libarchive-zip-perl \
    libmodule-build-perl \
    nano \
    wget \
    tar \
    make ;\
    cpan -i XML::Entities ;\
    /usr/sbin/a2dissite 000-default ;\
    /usr/sbin/a2enmod rewrite ;\
    /usr/sbin/a2enmod ssl ;\
    /usr/sbin/a2enmod authz_user ;\
    wget https://raw.githubusercontent.com/OCSInventory-NG/OCSInventory-Server/master/binutils/docker-download.sh ;\
    sh docker-download.sh 2.5
	
ENV TZ	"Europe/Paris"

WORKDIR /tmp/ocs/Apache
RUN perl Makefile.PL ;\
    make ;\
    make install ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone ;\
    cp -R blib/lib/Apache /usr/local/share/perl/5.28.0/ ;\
    cp -R Ocsinventory /usr/local/share/perl/5.28.0/ ;\
    cp /tmp/ocs/etc/logrotate.d/ocsinventory-server /etc/logrotate.d/ ;\
    mkdir -p /etc/ocsinventory-server/plugins ;\
    mkdir -p /etc/ocsinventory-server/perl ;\
    mkdir -p /usr/share/ocsinventory-reports/ocsreports

ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2f
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2
ENV OCS_DBSERVER_READ_PORT	3306
ENV OCS_DBSERVER_WRITE_PORT	3306

WORKDIR /tmp/ocs

RUN cp -R ocsreports/* /usr/share/ocsinventory-reports/ocsreports ;\
    bash -c 'mkdir -p /var/lib/ocsinventory-reports/{download,ipd,logs,scripts,snmp}' ;\
    chmod -R +w /var/lib/ocsinventory-reports ;\
    chown www-data: -R /var/lib/ocsinventory-reports ;\
    cp binutils/ipdiscover-util.pl /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl ;\
    chown www-data: /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl ;\
    chmod 755 /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl ;\
    mkdir -p /var/log/ocsinventory-server/ ;\
    chmod +w /var/log/ocsinventory-server ;\
    chown -R www-data: /usr/share/ocsinventory-reports/

COPY ./dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
COPY /conf/ocsinventory-reports.conf /conf/z-ocsinventory-server.conf /etc/apache2/conf-available/
COPY ./conf/php.ini /etc/php/7.0/apache2/php.ini
COPY ./scripts/run.sh /root/run.sh

RUN chown www-data: /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php ;\
    chmod +x /root/run.sh ;\
    ln -s /etc/apache2/conf-available/ocsinventory-reports.conf /etc/apache2/conf-enabled/ocsinventory-reports.conf ;\
    ln -s /etc/apache2/conf-available/z-ocsinventory-server.conf /etc/apache2/conf-enabled/z-ocsinventory-server.conf ;\
    rm /usr/share/ocsinventory-reports/ocsreports/install.php ;\
    rm -rf /tmp/ocs ;\
    apt-get clean ;\
    apt-get autoclean ;\
    apt-get autoremove ;\
    rm -rf /var/lib/apt/lists/* ;\
    rm -rf /var/cache/apt/archives/* ;

EXPOSE 80
EXPOSE 443

CMD ["/bin/bash", "/root/run.sh"]
