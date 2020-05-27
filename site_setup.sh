#!/bin/bash

XUSER="${1}"
XDOMAIN="${2}"
XSITENAME="${3}"
XDBNAME="${4}"
XDBUSER="${5}"
XDBPASS="${6}"
XDBHOST="localhost"

if [ -z "${XUSER}" ] || [ -z "${XDOMAIN}" ]; then
	echo "usage: ${0} user domain [sitename] [dbname] [dbuser] [dbpass]"
	echo "       sitename is optional, default to domain (replace . and - with _)"
	echo "       dbname   is optional, default to sitename"
	echo "       dbuser   is optional, default to sitename"
	echo "       dbpass   is optional, default to random generated"
	echo "       mariadb root user/pass required in /root/.mariadb-password file"
	echo "       in format user:pass"
	exit 1
fi

if ! [ -r "/root/.mariadb-password" ]; then
	echo "/root/.mariadb-password not found or not readable"
	exit 1
fi

if ! [ -r "/etc/httpd/conf.d/site.conf.template" ]; then
	echo "/etc/httpd/conf.d/site.conf.template not found or not readable"
	exit 1
fi

if ! [ -r "/etc/php-fpm.d/site.conf.template" ]; then
	echo "/etc/php-fpm.d/site.conf.template not found or not readable"
	exit 1
fi

XROOTDBINFO="$(cat /root/.mariadb-password)"
XROOTDBUSER="${XROOTDBINFO%%:*}"
XROOTDBPASS="${XROOTDBINFO##*:}"

if [ -z "${XROOTDBUSER}" ]; then
	echo "mysql root user is blank"
	exit 1
fi

if [ -z "${XSITENAME}" ]; then
	XSITENAME="${XDOMAIN}"
fi

XSITENAME="${XSITENAME/./_}"
XSITENAME="${XSITENAME/-/_}"


if [ -z "${XDBUSER}" ]; then
	XDBUSER="${XSITENAME}"
fi

if [ -z "${XDBPASS}" ]; then
	XDBPASS="$(hexdump -n 4 -e '4 "%08X" 1 "\n"' /dev/random)"
fi

if [ -z "${XDBNAME}" ]; then
	XDBNAME="${XSITENAME}"
fi

echo "user ${XUSER}"
echo "domain ${XDOMAIN}"
echo "sitename ${XSITENAME}"
echo "dbname ${XDBNAME}"
echo "dbuser ${XDBUSER}"
echo "dbpass ${XDBPASS}"
echo "dbhost ${XDBHOST}"

echo "Please take note of database user and password (if generated)"

SKIP_ADD_USER="0"
if [ -n "$(getent passwd "${XUSER}")" ]; then
	echo "system user ${XUSER} already exists"
	echo "to continue type 'continue' this will skip add system user"
	read CONT
	if [ "${CONT}" != "continue" ]; then
		exit 1
	fi
	SKIP_ADD_USER="1"
fi

if [ "${SKIP_ADD_USER}" != "1" ]; then

	echo "Adding user ${XUSER}"
	useradd -m ${XUSER}

	echo "Please set user ${XUSER} password"
	passwd ${XUSER}

fi

echo "Setting up Web Folder /home/${XUSER}/www"

chmod 755 /home/${XUSER}
mkdir -m 755 -p /home/${XUSER}/www/${XSITENAME}
mkdir -m 700 -p /home/${XUSER}/php/{log,session,wsdlcache,opcache}
chown -R ${XUSER}:${XUSER} /home/${XUSER}/www
chown -R ${XUSER}:${XUSER} /home/${XUSER}/php

#restorecon -R /home/${XUSER}/www/${XSITENAME}
chcon -R -t httpd_user_rw_content_t /home/${XUSER}/www/${XSITENAME}

#restorecon -R /home/${XUSER}/php
chcon -R -t httpd_log_t /home/${XUSER}/php/log
chcon -R -t httpd_var_run_t /home/${XUSER}/php/{session,wsdlcache,opcache}

echo "Setting up Apache Virtual Host Configuraiton"
cat /etc/httpd/conf.d/site.conf.template \
	| sed -e "s:__DOMAIN__:${XDOMAIN}:g" \
	| sed -e "s:__USER__:${XUSER}:g" \
	| sed -e "s:__SITENAME__:${XSITENAME}:g" > /etc/httpd/conf.d/100-${XSITENAME}.conf

echo "Setting up PHP-FPM Configuraiton"
cat /etc/php-fpm.d/site.conf.template \
	| sed -e "s:__DOMAIN__:${XDOMAIN}:g" \
	| sed -e "s:__USER__:${XUSER}:g" \
	| sed -e "s:__SITENAME__:${XSITENAME}:g" > /etc/php-fpm.d/100-${XSITENAME}.conf

echo "Creating Database"
echo -n -e "create database ${XDBNAME}" \
	| mysql "--user=${XROOTDBUSER}" "--password=${XROOTDBPASS}"
	
echo "Assign Database Privileges"
echo -n -e "grant all privileges on ${XDBNAME}.* to ${XDBUSER}@${XDBHOST} identified by '${XDBPASS}'" \
	| mysql "--user=${XROOTDBUSER}" "--password=${XROOTDBPASS}"
	
echo "Done."
