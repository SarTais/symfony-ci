FROM php:8.0-alpine

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
    php8-fpm \
    php8-common \
    php8-dev \
    php8-pecl-apcu \
    php8-opcache \
    php8-pecl-memcached \
    php8-curl \
    php8-ctype \
    php8-iconv \
    php8-tokenizer \
    php8-mbstring \
    php8-session \
    php8-imap \
    php8-xml \
    php8-simplexml \
    php8-xmlwriter \
    php8-xsl \
    php8-zip \
    php8-posix \
    php8-intl \
    php8-pdo \
    php8-pdo_mysql \
    php8-pdo_pgsql \
    php8-pdo_sqlite \
    php8-soap \
    php8-pecl-xdebug \
    php8-phpdbg \
    php8-gd

# Enable XDebug
RUN echo "zend_extension=xdebug.so" > /etc/php8/conf.d/50_xdebug.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update

# Node.js
RUN apk --no-cache add nodejs npm

# Yarn
RUN apk --no-cache add yarn

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm8", "-F"]
EXPOSE 9001 9003