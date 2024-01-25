FROM ubuntu:focal

# Arguments
ARG USER_ID=1000
ARG MAILHOG_VERSION=0.2.0

RUN usermod -u $USER_ID www-data

# Timezone
ENV TZ=UTC

# Base
RUN export LC_ALL=C.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# APT
RUN apt-get update && \
    apt-get install -y \
    apt-utils

# Common
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    openssh-client \
    rsync \
    software-properties-common \
    ssh \
    sudo \
    unzip \
    wget \
    zip \
    git

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    php7.0-fpm \
    php7.0-common \
    php7.0-dev \
    php7.0-cli \
    php7.0-amqp \
    php7.0-apcu \
    php7.0-apcu-bc \
    php7.0-opcache \
    php7.0-memcached \
    php7.0-curl \
    php7.0-ctype \
    php7.0-iconv \
    php7.0-tokenizer \
    php7.0-mbstring \
    php7.0-imap \
    php7.0-json \
    php7.0-xml \
    php7.0-simplexml \
    php7.0-xmlwriter \
    php7.0-xmlrpc \
    php7.0-xsl \
    php7.0-zip \
    php7.0-bz2 \
    php7.0-posix \
    php7.0-intl \
    php7.0-pdo \
    php7.0-mysql \
    php7.0-pgsql \
    php7.0-sqlite3 \
    php7.0-soap \
    php7.0-gd \
    php7.0-gmp \
    php7.0-ldap \
    php7.0-bcmath \
    php7.0-geoip \
    php7.0-gmagick \
    php7.0-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php7.0-fpm.pid && \
    chown $USER_ID:www-data /run/php/php7.0-fpm.pid

# Enable CLI debuging
RUN echo 'php -dxdebug.client_host=$REMOTE_HOST $@' > /usr/local/bin/php_debug \
    && chmod +x /usr/local/bin/php_debug

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update

# Mailhog
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v$MAILHOG_VERSION/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm7.0", "-F"]
EXPOSE 9000 9001 9003