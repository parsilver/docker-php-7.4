FROM php:7.4-apache

WORKDIR /var/www/project

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    ffmpeg \
    libmagickwand-dev \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*


# # Enable redis
RUN pecl install redis && docker-php-ext-enable redis

# # Enable imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# # Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl xml iconv intl opcache
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd


# Install cacert pem
RUN curl --remote-name --time-cond cacert.pem https://curl.haxx.se/ca/cacert.pem \
    && mkdir -p /etc/ssl/certs/ \
    && cp cacert.pem /etc/ssl/certs/ \
    && chown -R www-data:www-data /etc/ssl/certs/cacert.pem

# Setup php
RUN echo "curl.cainfo=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.cafile=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.capath=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini

COPY local.ini /usr/local/etc/php/conf.d/app.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opacache.ini

COPY apache.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80