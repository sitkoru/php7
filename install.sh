#!/bin/bash
gdpat="7.3.*"
memcachepat="8.*.*"
apt update && apt install -y \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-tools \
    libpng-dev \
    libxslt-dev \
    libpq-dev \
    libzip-dev \
    libmemcached-dev \
    libgmp-dev \
    binutils \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && if [[ $PHP_VERSION =~ $gdpat ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; else docker-php-ext-configure gd --with-freetype --with-jpeg; fi \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo \
    && MAKEFLAGS="-j $(nproc)" pecl install redis \
    && docker-php-ext-enable redis \
    && MAKEFLAGS="-j $(nproc)" pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && MAKEFLAGS="-j $(nproc)" pecl install grpc \
    && docker-php-ext-enable grpc \
    && MAKEFLAGS="-j $(nproc)" pecl install memcached-3.1.5 \
    && docker-php-ext-enable memcached \
    && if [[ $PHP_VERSION =~ $memcachepat ]]; then pecl install memcache-8.0; else pecl install memcache-4.0.5.2; fi \
    && docker-php-ext-enable memcache \
    && strip --strip-debug $(php-config --extension-dir)/*.so