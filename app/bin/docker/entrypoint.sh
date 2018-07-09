#!/bin/bash
echo "enter /app/bin/docker/entrypoint.sh"


# clean some variables
export uid=${uid:=1000}
export gid=${gid:=1000}
export group=filerun
export username=filerun
export MYSQL_HOSTNAME=${MYSQL_HOSTNAME:=db}
export MYSQL_DATABASE=${MYSQL_DATABASE:=filerun}
export MYSQL_USER=${MYSQL_USER:=filerun}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:=filerun}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:=filerun}



# add user and set permissions
echo "Setup user and permissions"
groupadd --gid $gid $group
useradd --home-dir /home/$username --no-create-home --non-unique --gid $gid --uid $uid --no-user-group --shell /usr/sbin/nologin $username
usermod -aG sudo $username
chown -Rf $username:$group /var/www/html
chown -Rf $username:$group /var/run/apache2*
chown -Rf $username:$group /var/lock/apache2*
chown -Rf $username:$group /var/log/apache2*
chown $username:$group /user-files


# db settings
echo "Setup database"
echo "<?php" > /var/www/html/system/data/autoconfig.php
echo "\$config['db'] = [" >> /var/www/html/system/data/autoconfig.php
echo "  'type' => 'mysql'," >> /var/www/html/system/data/autoconfig.php
echo "  'server' => '$MYSQL_HOSTNAME'," >> /var/www/html/system/data/autoconfig.php
echo "  'database' => '$MYSQL_DATABASE'," >> /var/www/html/system/data/autoconfig.php
echo "  'username' => '$MYSQL_USER'," >> /var/www/html/system/data/autoconfig.php
echo "  'password' => '$MYSQL_PASSWORD'" >> /var/www/html/system/data/autoconfig.php
echo "];" >> /var/www/html/system/data/autoconfig.php
/app/bin/wait-for-it.sh $MYSQL_HOSTNAME:3306 -t 120 -- /app/bin/db.setup.sh



# start app
echo "Start"
export APACHE_RUN_USER=${username:=www-data}
export APACHE_RUN_GROUP=${group:=www-data}
source /etc/apache2/envvars
apache2 -D FOREGROUND -D LOGSTDOUT



# stop app
echo "Stop "
if [ "$development" = "true" ]; then
    echo "Holding container up for debug."
    while :; do
      date
      sleep 300
    done
fi
echo "Holding container for 30s to avoid restart-flood"
sleep 30
echo "Exit container"
