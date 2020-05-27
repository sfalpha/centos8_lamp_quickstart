# centos8_lamp_quickstart
Templates and Scripts for quick CentOS 8 LAMP server setup

# usage (bootstrap)

download scripts

sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/centos8_setup_default.sh

sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/etc_template.tar

run

chmod +x ./centos8_setup_default.sh

sudo ./centos8_setup_default.sh

# usage (site setup)

download scripts

sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/site_setup.sh

create mysql admin/root password file /root/.mariadb-password in format user:password

sudo 'echo "MYSQLROOTUSER:MYSQLROOTPASS" > /root/.mariadb-password'

run site-setup

chmod +x ./site-setup.sh

sudo ./site-setup.sh SYSTEMUSER DOMAIN SITENAME DBNAME DBUSER DBPASS

example

sudo ./site-setup.sh myuser mydomain.com mysite mysite mysite m1s2t3
