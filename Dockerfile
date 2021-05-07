FROM ubuntu:focal

ARG USER_ID=1000
RUN usermod -u $USER_ID www-data

# Timezone
ENV TZ=Europe/Kiev

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

# Git
RUN add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    php8.0-fpm \
    php8.0-common \
    php8.0-dev \
    php8.0-cli \
    php8.0-amqp \
    php8.0-apcu \
    php-apcu-bc \
    php8.0-opcache \
    php8.0-memcached \
    php8.0-curl \
    php8.0-ctype \
    php8.0-iconv \
    php8.0-tokenizer \
    php8.0-mbstring \
    php8.0-imap \
    php8.0-xml \
    php8.0-simplexml \
    php8.0-xmlwriter \
    php8.0-xmlrpc \
    php8.0-xsl \
    php8.0-zip \
    php8.0-bz2 \
    php8.0-posix \
    php8.0-intl \
    php8.0-pdo \
    php8.0-mysql \
    php8.0-pgsql \
    php8.0-sqlite3 \
    php8.0-soap \
    php8.0-gd \
    php8.0-gmp \
    php8.0-ldap \
    php8.0-bcmath \
    php-geoip \
    php-gmagick \
    php8.0-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && touch /run/php/php8.0-fpm.pid && chown $USER_ID:www-data /run/php/php8.0-fpm.pid

# Enable CLI debuging
RUN echo 'php -dxdebug.client_host=$REMOTE_HOST $@' > /usr/local/bin/php_debug \
    && chmod +x /usr/local/bin/php_debug

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x -o node_setup.sh && \
    bash node_setup.sh && \
    apt-get install -y nodejs && \
    npm install npm -g

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

# Mailhog
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# SSH
RUN mkdir ~/.ssh && touch ~/.ssh_config

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm8.0", "-F"]
EXPOSE 9000 9001 9003