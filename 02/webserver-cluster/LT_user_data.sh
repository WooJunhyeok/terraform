#!/bin/bash
# Apache Web Server User Data Script
yum -q -y install httpd mod_ssl
echo "My Web Server" > /var/www/html/index.html
systemctl enable --now httpd
