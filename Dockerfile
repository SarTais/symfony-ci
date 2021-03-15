FROM php:5.6-alpine

# Common
RUN apk update && \
    apk upgrade && \
    apk --no-cache add \
    openssh-client \
    libmemcached-libs \
    libevent \
    libssl1.0 \
    yaml \
    curl \
    wget \
    bash \
    zip \
    git
    
#PHP
RUN apk update && \
    apk upgrade && \
    apk --no-cache add \
    php5-fpm \
    php5-common \
    php5-dev \
    php5-apcu \
    php5-opcache \
    php5-curl \
    php5-ctype \
    php5-iconv \
    php5-imap \
    php5-json \
    php5-xml \
    php5-xsl \
    php5-zip \
    php5-posix \
    php5-intl \
    php5-pdo \
    php5-pdo_mysql \
    php5-pdo_pgsql \
    php5-pdo_sqlite \
    php5-soap \
    php5-phpdbg \
    php5-gd

ENV PHP_INI_DIR /etc/php5
ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c php5-dev php5-pear \
    yaml-dev zlib-dev libmemcached-dev cyrus-sasl-dev libevent-dev openssl-dev

RUN set -xe && \
    apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS

# Install and enable xdebug
RUN pecl channel-update pecl.php.net && \
    pecl install xdebug-2.5.5 && \
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > $PHP_INI_DIR/conf.d/xdebug.ini

# Install and enable memcached
RUN pecl install memcached-2.2.0 && \
    echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/memcached.so" > $PHP_INI_DIR/conf.d/memcached.ini

# Remove deps
RUN rm -rf /usr/share/php && \
    rm -rf /tmp/* && \
    apk del .phpize-deps

# Composer
RUN apk --no-cache add composer

# Node.js
RUN apk --no-cache add nodejs npm

# Yarn
RUN apk --no-cache add yarn

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm5", "-F"]
EXPOSE 9000 9001