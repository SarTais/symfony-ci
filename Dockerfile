FROM composer:2 AS composer

FROM php:8.5-cli-alpine

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apk add --no-cache \
        freetype \
        git \
        icu-libs \
        libjpeg-turbo \
        libpng \
        libzip \
        unzip \
    && apk add --no-cache --virtual .php-build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        ftp \
        gd \
        intl \
        pcntl \
        pdo_mysql \
        zip \
    && pecl install protobuf-5.35.0 \
    && docker-php-ext-enable protobuf \
    && apk del .php-build-deps

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www
