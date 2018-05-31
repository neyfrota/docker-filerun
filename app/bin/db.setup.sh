#!/bin/bash
echo "enter /app/bin/db.setup.sh"

# clean some variables
export MYSQL_HOSTNAME=${MYSQL_HOSTNAME:=db}
export MYSQL_DATABASE=${MYSQL_DATABASE:=filerun}
export MYSQL_USER=${MYSQL_USER:=filerun}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:=filerun}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:=filerun}



if [ $(mysql -N -s --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOSTNAME  -e "select count(*) from information_schema.tables where table_schema='${MYSQL_DATABASE}' and table_name='df_users';") -eq 1 ]; then
	echo "databese is already setup ...";
else
	echo "Databese need setup"
	mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_HOSTNAME $MYSQL_DATABASE < /app/etc/db.setup.sql
	mkdir -p /user-files/superuser
	chown $username:$group /user-files/superuser
fi
exit;
