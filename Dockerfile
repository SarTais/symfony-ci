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
    echo 'Acquire::AllowReleaseInfoChange::Label "true";' > /etc/apt/apt.conf.d/99allow-releaseinfo-change-label && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y \
    php8.5-fpm \
    php8.5-common \
    php8.5-dev \
    php8.5-cli \
    php8.5-amqp \
    php8.5-apcu \
    php8.5-memcached \
    php8.5-curl \
    php8.5-ctype \
    php8.5-iconv \
    php8.5-tokenizer \
    php8.5-mbstring \
    php8.5-imap \
    php8.5-xml \
    php8.5-simplexml \
    php8.5-xmlwriter \
    php8.5-xmlrpc \
    php8.5-xsl \
    php8.5-zip \
    php8.5-bz2 \
    php8.5-posix \
    php8.5-intl \
    php8.5-pdo \
    php8.5-mysql \
    php8.5-pgsql \
    php8.5-sqlite3 \
    php8.5-soap \
    php8.5-gd \
    php8.5-gmp \
    php8.5-ldap \
    php8.5-bcmath \
    php8.5-protobuf \
    php8.5-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php8.5-fpm.pid && \
    chown $USER_ID:www-data /run/php/php8.5-fpm.pid

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

CMD ["php-fpm8.5", "-F"]
EXPOSE 9000 9001 9003
