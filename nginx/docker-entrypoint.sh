#!/bin/bash

if [ -f "$APP_BEFORE_START_SCRIPT" ]; then
    echo "$APP_BEFORE_START_SCRIPT exists."
    bash $APP_BEFORE_START_SCRIPT
fi


touch /var/log/php-fpm.log
php-fpm >/var/log/php-fpm.log 2>&1 &
nginx -g "daemon off;" &

tail -qf --follow=name --retry /var/log/php-fpm.log /var/log/nginx/access.log /var/log/nginx/error.log