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
    php8.1-fpm \
    php8.1-common \
    php8.1-dev \
    php8.1-cli \
    php8.1-amqp \
    php8.1-apcu \
    php8.1-opcache \
    php8.1-memcached \
    php8.1-curl \
    php8.1-ctype \
    php8.1-iconv \
    php8.1-tokenizer \
    php8.1-mbstring \
    php8.1-imap \
    php8.1-xml \
    php8.1-simplexml \
    php8.1-xmlwriter \
    php8.1-xmlrpc \
    php8.1-xsl \
    php8.1-zip \
    php8.1-bz2 \
    php8.1-posix \
    php8.1-intl \
    php8.1-pdo \
    php8.1-mysql \
    php8.1-pgsql \
    php8.1-sqlite3 \
    php8.1-soap \
    php8.1-gd \
    php8.1-gmp \
    php8.1-ldap \
    php8.1-bcmath \
    php8.1-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php8.1-fpm.pid && \
    chown $USER_ID:www-data /run/php/php8.1-fpm.pid

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

CMD ["php-fpm8.1", "-F"]
EXPOSE 9000 9001 9003