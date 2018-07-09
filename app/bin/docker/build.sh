#!/bin/bash
echo "enter /app/bin/docker/build.sh"
cd /tmp/

# Cleanup env variables
export MYSQL_HOSTNAME=${MYSQL_HOSTNAME:=db}
export MYSQL_DATABASE=${MYSQL_DATABASE:=filerun}
export MYSQL_USER=${MYSQL_USER:=filerun}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:=filerun}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:=filerun}


# update repo index
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y dnsmasq


# in case you need human interaction:
apt-get install -y net-tools iputils-ping vim curl dnsutils


# add PHP, extensions and third-party software
apt-get install -y libapache2-mod-xsendfile libfreetype6-dev libjpeg62-turbo-dev dcraw libcurl4-gnutls-dev locales graphicsmagick mysql-client unzip
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-install -j$(nproc) pdo_mysql exif zip gd opcache


# set recommended PHP.ini settings
# see http://docs.filerun.com/php_configuration
ln -s /app/etc/filerun-optimization.ini /usr/local/etc/php/conf.d/filerun-optimization.ini


# Install ionCube
curl -O http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xvfz ioncube_loaders_lin_x86-64.tar.gz
PHP_EXT_DIR=$(php-config --extension-dir)
cp "ioncube/ioncube_loader_lin_7.2.so" $PHP_EXT_DIR
echo "zend_extension=ioncube_loader_lin_7.2.so" >> /usr/local/etc/php/conf.d/00_ioncube_loader_lin_7.2.ini


# Get FileRun
curl -o filerun.zip -L https://www.filerun.com/download-latest-php71
unzip filerun.zip -d /var/www/html/


# configure apache
#
echo "<?php" > /var/www/html/system/data/autoconfig.php
echo "\$config['db'] = [" >> /var/www/html/system/data/autoconfig.php
echo "  'type' => 'mysql'," >> /var/www/html/system/data/autoconfig.php
echo "  'server' => '$MYSQL_HOSTNAME'," >> /var/www/html/system/data/autoconfig.php
echo "  'database' => '$MYSQL_DATABASE'," >> /var/www/html/system/data/autoconfig.php
echo "  'username' => '$MYSQL_USER'," >> /var/www/html/system/data/autoconfig.php
echo "  'password' => '$MYSQL_PASSWORD'" >> /var/www/html/system/data/autoconfig.php
echo "];" >> /var/www/html/system/data/autoconfig.php
#
mkdir /user-files
ln -s /app/etc/conf-available-filerun.conf /etc/apache2/conf-available/filerun.conf
a2enconf filerun
#
rm -f /etc/apache2/conf-enabled/other-vhosts-access-log.conf
rm -f /etc/apache2/conf-enabled/localized-error-pages.conf
rm -f /etc/apache2/conf-enabled/serve-cgi-bin.conf
#
rm -f /etc/apache2/conf-enabled/security.conf
echo "ServerTokens Minimal" >> /etc/apache2/conf-enabled/security.conf
echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf
echo "TraceEnable Off" >> /etc/apache2/conf-enabled/security.conf
#
service apache2 stop


# clean the house
apt-get autoremove -y
apt-get autoclean -y
apt-get clean all -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
