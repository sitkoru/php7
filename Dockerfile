FROM php:7.1.23-fpm

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
    libpng16-16 \
    libpng-dev \
    libxslt1.1 \
    libxslt-dev \
    libpq5 \
    libpq-dev \
    bash-completion \
    wget \
    locales \
    locales-all \
    sudo \
    mysql-client \
    postgresql-client-10 \
    duplicity \
    zip \
    libgmp-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp \
    && curl -fsS -o /tmp/icu.tgz -L http://download.icu-project.org/files/icu4c/59.1/icu4c-59_1-src.tgz \
    && tar -zxf /tmp/icu.tgz -C /tmp \
    && cd /tmp/icu/source \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    # just to be certain things are cleaned up
    && rm -rf /tmp/icu* \
    && PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11" docker-php-ext-configure intl --with-icu-dir=/usr/local \
    # run configure and install in the same RUN line, they extract and clean up the php source to save space
    && PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11" docker-php-ext-install intl \
    && pecl install redis-4.0.0 \
    && docker-php-ext-enable redis \
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
        libicu-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc

RUN chown -R www-data:www-data /var/www

RUN echo "www-data:www-data" | chpasswd && adduser www-data sudo
RUN echo "www-data ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

RUN echo Europe/Moscow | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN rm /usr/local/etc/php-fpm.d/www.conf.default && rm /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY php.ini /usr/local/etc/php/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer

USER www-data
WORKDIR /var/www

RUN composer global require "fxp/composer-asset-plugin:^1.4.2" --prefer-dist
RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist

CMD ["php-fpm"]
