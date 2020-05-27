#!/bin/bash

QS_BASE_FOLDER="."

echo "Setting up yum repo"
yum -y install dnf-plugins-core
yum -y install epel-release
yum config-manager --set-enabled PowerTools

echo "Installing core LAMP packages"
yum -y install httpd mod_ssl mariadb-server php-cgi php-cli php-fpm php-mysqlnd php-gd php-xml php-intl php-zip php-mbstring php-soap php-curl php-openssl php-json php-opcache

echo "Installing Required system tools"
yum -y install tar policycoreutils-python-utils certbot

echo "Settting up SELINUX policies and context"
setsebool -P httpd_can_network_connect=on httpd_can_network_connect_db=on httpd_can_sendmail=on httpd_enable_homedirs=on httpd_enable_cgi=on httpd_read_user_content=on httpd_setrlimit=on
semanage fcontext -a -t httpd_log_t "/home/[^/]+/php/log(/.*)?"
semanage fcontext -a -t httpd_var_run_t "/home/[^/]+/php/session(/.*)?"
semanage fcontext -a -t httpd_var_run_t "/home/[^/]+/php/wsdlcache(/.*)?"
semanage fcontext -a -t httpd_var_run_t "/home/[^/]+/php/opcache(/.*)?"

echo "Setting up firewall"
firewall-cmd --add-service http
firewall-cmd --add-service https
firewall-cmd --runtime-to-permanent

echo "Setting up MariaDB"
systemctl start mariadb

echo "Please follow instructions to setup mariadb"
mysql_secure_installation

echo "Setting up default apache and php-fpm config and templates"
tar -C / --xattrs -xvpf ${QS_BASE_FOLDER}/etc_template.tar

echo "Enabling services"
systemctl enable mariadb
systemctl enable httpd
systemctl enable php-fpm

echo "Initizize apache self sign cert"
FQDN="$(hostname)"
sscg -q                                                             \
     --cert-file           /etc/pki/tls/certs/localhost.crt         \
     --cert-key-file       /etc/pki/tls/private/localhost.key       \
     --ca-file             /etc/pki/tls/certs/localhost.crt         \
     --lifetime            365                                      \
     --hostname            $FQDN                                    \
     --email               root@$FQDN


echo "setup finished"
echo ""
echo "If you want to use quick site setup script (site_setup.sh)"
echo "please create /root/.mariadb-password and specify"
echo "mysql admin user and password in format 'user:password' (without quote)"
echo ""

