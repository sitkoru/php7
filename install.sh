#!/bin/bash

apt update && apt install -y \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6 \
    libfreetype6-dev \
    libjpeg62-turbo \
    libjpeg-dev \
    libpng-tools \
    libpng16-16 \
    libpng-dev \
    libxslt1.1 \
    libxslt-dev \
    libpq5 \
    libpq-dev \
    libzip4 \
    libzip-dev \
    libmemcached-dev \
    bash-completion \
    wget \
    locales \
    locales-all \
    zip \
    libgmp-dev \
    python3-distutils \
    mariadb-client \
    postgresql-client-11 \
    duplicity \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && if [[ $PHP_VERSION =~ "7.3.*" ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; else docker-php-ext-configure gd --with-freetype --with-jpeg; fi \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && pecl install grpc \
    && docker-php-ext-enable grpc \
    && pecl install memcached-3.1.5 \
    && docker-php-ext-enable memcached \
    && pecl install memcache-4.0.5.2 \
    && docker-php-ext-enable memcache \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    autoconf \
    binutils \
    gcc \
    libc-dev \
    g++ \
    make \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libxslt-dev \
    libxml2-dev \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale