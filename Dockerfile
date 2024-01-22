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
    zip

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    php8.3-fpm \
    php8.3-common \
    php8.3-dev \
    php8.3-cli \
    php8.3-amqp \
    php8.3-apcu \
    php8.3-opcache \
    php8.3-memcached \
    php8.3-curl \
    php8.3-ctype \
    php8.3-iconv \
    php8.3-tokenizer \
    php8.3-mbstring \
    php8.3-imap \
    php8.3-xml \
    php8.3-simplexml \
    php8.3-xmlwriter \
    php8.3-xmlrpc \
    php8.3-xsl \
    php8.3-zip \
    php8.3-bz2 \
    php8.3-posix \
    php8.3-intl \
    php8.3-pdo \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-sqlite3 \
    php8.3-soap \
    php8.3-gd \
    php8.3-gmp \
    php8.3-ldap \
    php8.3-bcmath \
    php8.3-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php8.3-fpm.pid && \
    chown $USER_ID:www-data /run/php/php8.3-fpm.pid

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

CMD ["php-fpm8.3", "-F"]
EXPOSE 9000 9001 9003