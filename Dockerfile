FROM php:7.4-alpine

# Common
RUN apk update && \
    apk upgrade && \
    apk --no-cache add \
    curl \
    wget \
    bash \
    zip \
    git

#PHP
RUN apk update && \
    apk upgrade && \
    apk --no-cache add \
    php7-fpm \
    php7-common \
    php7-dev \
    php7-pecl-apcu \
    php7-pecl-amqp \
    php7-opcache \
    php7-pecl-memcached \
    php7-curl \
    php7-ctype \
    php7-iconv \
    php7-tokenizer \
    php7-mbstring \
    php7-session \
    php7-imap \
    php7-json \
    php7-xml \
    php7-simplexml \
    php7-xmlwriter \
    php7-xsl \
    php7-zip \
    php7-posix \
    php7-intl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-soap \
    php7-pecl-xdebug \
    php7-phpdbg \
    php7-gd

# Enable XDebug
RUN echo "zend_extension=xdebug.so" > /etc/php7/conf.d/50_xdebug.ini

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

CMD ["php-fpm7", "-F"]
EXPOSE 9001 9003