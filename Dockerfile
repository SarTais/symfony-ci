FROM ubuntu:jammy

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
    php8.4-fpm \
    php8.4-common \
    php8.4-dev \
    php8.4-cli \
    php8.4-amqp \
    php8.4-apcu \
    php8.4-opcache \
    php8.4-memcached \
    php8.4-curl \
    php8.4-ctype \
    php8.4-iconv \
    php8.4-tokenizer \
    php8.4-mbstring \
    php8.4-imap \
    php8.4-xml \
    php8.4-simplexml \
    php8.4-xmlwriter \
    php8.4-xmlrpc \
    php8.4-xsl \
    php8.4-zip \
    php8.4-bz2 \
    php8.4-posix \
    php8.4-intl \
    php8.4-pdo \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-sqlite3 \
    php8.4-soap \
    php8.4-gd \
    php8.4-gmp \
    php8.4-ldap \
    php8.4-bcmath \
    php8.4-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php8.4-fpm.pid && \
    chown $USER_ID:www-data /run/php/php8.4-fpm.pid

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

CMD ["php-fpm8.4", "-F"]
EXPOSE 9000 9001 9003
