FROM php:7.3-fpm

ENV LANG=C.UTF-8

RUN apt update && apt install -y gnupg

RUN echo deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt update && apt install -y \
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
    bash-completion \
    wget \
    locales \
    locales-all \
    zip \
    libgmp-dev \
    python3-distutils \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && pecl install grpc \
    && docker-php-ext-enable grpc \
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

RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc

RUN echo Europe/Moscow | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
