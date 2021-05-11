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
    && docker-php-source extract \
    && pecl bundle -d /usr/src/php/ext redis \
    && docker-php-ext-install -j$(nproc) redis \
    && pecl bundle -d /usr/src/php/ext mongodb \
    && docker-php-ext-install -j$(nproc) mongodb \
    && pecl bundle -d /usr/src/php/ext grpc \
    && docker-php-ext-install -j$(nproc) grpc \
    && pecl bundle -d /usr/src/php/ext memcached-3.1.5 \
    && docker-php-ext-install -j$(nproc) memcached \
    && docker-php-ext-configure gmp \
    && if [[ $PHP_VERSION =~ $gdpat ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; else docker-php-ext-configure gd --with-freetype --with-jpeg; fi \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo \
    && if [[ $PHP_VERSION =~ $memcachepat ]]; then pecl bundle -d /usr/src/php/ext memcache-8.0; else pecl bundle -d /usr/src/php/ext memcache-4.0.5.2; fi \
    && docker-php-ext-install memcache \
    && docker-php-source delete \
    && strip --strip-debug $(php-config --extension-dir)/*.so