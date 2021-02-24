ARG PHP_VERSION=7
FROM php:${PHP_VERSION}-fpm as build

ENV LANG=C.UTF-8

RUN apt update && apt install -y gnupg

RUN echo deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

COPY install.sh /install.sh

RUN PHP_VERSION=${PHP_VERSION} bash /install.sh

FROM php:${PHP_VERSION}-fpm as base

RUN apt-get update \
    && apt-get install -y bash-completion wget zip msmtp  \
    libpng16-16 \ 
    libjpeg62-turbo \
    libfreetype6 \
    libpq5 \
    libzip4 \
    libxslt1.1 \
    locales \
    locales-all \
    libmemcached11 \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/*

RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

COPY --from=build /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions

COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc

RUN echo Europe/Moscow | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN rm /usr/local/etc/php-fpm.d/www.conf.default && rm /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
RUN sed -i "s/php_version/php${PHP_VERSION}/g" /usr/local/etc/php-fpm.conf

WORKDIR /var/www

CMD ["php-fpm"]

FROM base as dev

RUN apt update \
    && apt install -y $PHPIZE_DEPS openssh-server git unzip rsync \
    && pecl install xdebug ast \
    && docker-php-ext-enable ast \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer

FROM base as fpm 

COPY php.ini /usr/local/etc/php/

FROM fpm as ssh

COPY ssh-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN apt update \
    && apt install -y openssh-server rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /run/sshd
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \ 
    && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
    && sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
    && sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config

CMD ["/docker-entrypoint.sh"]