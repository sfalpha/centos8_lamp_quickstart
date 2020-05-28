# centos8_lamp_quickstart
Templates and Scripts for quick CentOS 8 LAMP server setup

This provides simple way for setup LAMP stack that support multiple
system user (for SFTP/SSH) and muitple websites.

Each site has it own PHP-FPM process and run on user privileges.

## Bootstrapping (install Apache, PHP-FPM and required packages for site-setup script)

### download

`sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/centos8_setup_default.sh`

`sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/etc_template.tar`

### run

`chmod +x ./centos8_setup_default.sh`

`sudo ./centos8_setup_default.sh`

## Site setup (setup system-user, Apache and PHP-FPM configuration for a website/domain)

### download

`sudo curl -LJO https://github.com/sfalpha/centos8_lamp_quickstart/raw/master/site_setup.sh`

### prepare mysql admin/root password file

create mysql admin/root password file /root/.mariadb-password in format user:password

`sudo 'echo "MYSQLROOTUSER:MYSQLROOTPASS" > /root/.mariadb-password'`

### run

`chmod +x ./site-setup.sh`

`sudo ./site-setup.sh SYSTEMUSER DOMAIN SITENAME DBNAME DBUSER DBPASS`

### example

`sudo ./site-setup.sh myuser mydomain.com mysite mysite mysite m1s2t3`
