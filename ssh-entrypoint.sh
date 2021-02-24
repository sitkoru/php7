#!/bin/bash
touch /var/log/php-fpm.log
php-fpm >/var/log/php-fpm.log 2>&1 &

touch /var/log/sshd.log
/usr/bin/ssh-keygen -A
/usr/sbin/sshd >/var/log/sshd.log 2>&1 &

tail -f /var/log/php-fpm.log