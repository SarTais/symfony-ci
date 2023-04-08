FROM ubuntu:focal

# Arguments
ARG USER_ID=1000
ARG NODE_JS_VERSION=18
ARG NODE_JS_SPECIFIC_VERSION
ARG NODE_JS_PLATFORM=x64
ARG NPM_VERSION=latest
ARG YARN_VERSION=latest
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

# Git
RUN add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    php7.2-fpm \
    php7.2-common \
    php7.2-dev \
    php7.2-cli \
    php7.2-amqp \
    php7.2-apcu \
    php7.2-apcu-bc \
    php7.2-opcache \
    php7.2-memcached \
    php7.2-curl \
    php7.2-ctype \
    php7.2-iconv \
    php7.2-tokenizer \
    php7.2-mbstring \
    php7.2-imap \
    php7.2-json \
    php7.2-xml \
    php7.2-simplexml \
    php7.2-xmlwriter \
    php7.2-xmlrpc \
    php7.2-xsl \
    php7.2-zip \
    php7.2-bz2 \
    php7.2-posix \
    php7.2-intl \
    php7.2-pdo \
    php7.2-mysql \
    php7.2-pgsql \
    php7.2-sqlite3 \
    php7.2-soap \
    php7.2-gd \
    php7.2-gmp \
    php7.2-ldap \
    php7.2-bcmath \
    php7.2-geoip \
    php7.2-gmagick \
    php7.2-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php7.2-fpm.pid && \
    chown $USER_ID:www-data /run/php/php7.2-fpm.pid

# Enable CLI debuging
RUN echo 'php -dxdebug.client_host=$REMOTE_HOST $@' > /usr/local/bin/php_debug \
    && chmod +x /usr/local/bin/php_debug

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    composer self-update

# NodeJS + NPM + Yarn
ENV PATH="/nodejs/bin:${PATH}"
RUN if [ -z "$NODE_JS_SPECIFIC_VERSION" ] ; then \
    curl -sL https://deb.nodesource.com/setup_$NODE_JS_VERSION.x -o node_setup.sh && \
    bash node_setup.sh && \
    apt-get install -y nodejs && \
    npm install -g npm@$NPM_VERSION && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf node_setup.sh \
; else \
    curl -O https://nodejs.org/download/release/v$NODE_JS_SPECIFIC_VERSION/node-v$NODE_JS_SPECIFIC_VERSION-linux-$NODE_JS_PLATFORM.tar.gz && \
    tar xzf node-v$NODE_JS_SPECIFIC_VERSION-linux-$NODE_JS_PLATFORM.tar.gz && \
    mv node-v$NODE_JS_SPECIFIC_VERSION-linux-$NODE_JS_PLATFORM nodejs && \
    rm -rf node-v$NODE_JS_SPECIFIC_VERSION-linux-$NODE_JS_PLATFORM.tar.gz &&  \
    npm install -g yarn@$YARN_VERSION \
; fi

RUN if [ -n "$NODE_JS_SPECIFIC_VERSION" ] && [ "$NPM_VERSION" != "latest" ]; then \
    npm install -g agentkeepalive --save && \
    npm install -g npm@$NPM_VERSION \
; fi

# Mailhog
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v$MAILHOG_VERSION/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# SSH
RUN mkdir ~/.ssh && touch ~/.ssh_config

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

CMD ["php-fpm7.2", "-F"]
EXPOSE 9000 9001 9003