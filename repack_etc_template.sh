#!/bin/bash

rm -f etc_template.tar
tar --xattrs -C / -cvf etc_template.tar etc/httpd/conf.d/{welcome.conf,ssl.conf,site.conf.template} etc/php-fpm.d/{www.conf,site.conf.template}
