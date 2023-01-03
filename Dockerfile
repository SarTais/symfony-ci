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
    php7.4-fpm \
    php7.4-common \
    php7.4-dev \
    php7.4-cli \
    php7.4-amqp \
    php7.4-apcu \
    php7.4-apcu-bc \
    php7.4-opcache \
    php7.4-memcached \
    php7.4-curl \
    php7.4-ctype \
    php7.4-iconv \
    php7.4-tokenizer \
    php7.4-mbstring \
    php7.4-imap \
    php7.4-json \
    php7.4-xml \
    php7.4-simplexml \
    php7.4-xmlwriter \
    php7.4-xmlrpc \
    php7.4-xsl \
    php7.4-zip \
    php7.4-bz2 \
    php7.4-posix \
    php7.4-intl \
    php7.4-pdo \
    php7.4-mysql \
    php7.4-pgsql \
    php7.4-sqlite3 \
    php7.4-soap \
    php7.4-gd \
    php7.4-gmp \
    php7.4-ldap \
    php7.4-bcmath \
    php7.4-geoip \
    php7.4-gmagick \
    php7.4-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && touch /run/php/php7.4-fpm.pid && chown $USER_ID:www-data /run/php/php7.4-fpm.pid

# Enable CLI debuging
RUN echo 'php -dxdebug.client_host=$REMOTE_HOST $@' > /usr/local/bin/php_debug \
    && chmod +x /usr/local/bin/php_debug

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update --2

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
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm7.4", "-F"]
EXPOSE 9000 9001 9003