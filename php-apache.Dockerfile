FROM php:7.4-apache

WORKDIR /project

RUN apt-get update && apt-get install -y curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    ffmpeg \
    libmagickwand-dev \
    imagemagick \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*


# # Enable redis
RUN pecl install redis && docker-php-ext-enable redis

# # Enable imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# # Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl xml iconv intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

EXPOSE 80