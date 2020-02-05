FROM php:7.4-fpm-alpine

MAINTAINER PA <parkorn.ap@gmail.com>

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev

RUN apk --update add curl \
    git \
    imagemagick \
    icu \
    icu-dev \
    libzip-dev \
    libintl \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    supervisor


# Enable redis
RUN pecl install redis && docker-php-ext-enable redis

# Enable imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl xml iconv intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

RUN apk del -f .build-deps \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/www

# Install cacert pem
RUN curl --remote-name --time-cond cacert.pem https://curl.haxx.se/ca/cacert.pem \
    && mkdir -p /etc/ssl/certs/ \
    && cp cacert.pem /etc/ssl/certs/ \
    && chown -R www-data:www-data /etc/ssl/certs/cacert.pem

# Setup php
RUN echo "curl.cainfo=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.cafile=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.capath=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini

COPY ./local.ini /usr/local/etc/php/conf.d/app.ini