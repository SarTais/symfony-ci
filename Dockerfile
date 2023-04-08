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
    php7.3-fpm \
    php7.3-common \
    php7.3-dev \
    php7.3-cli \
    php7.3-amqp \
    php7.3-apcu \
    php7.3-apcu-bc \
    php7.3-opcache \
    php7.3-memcached \
    php7.3-curl \
    php7.3-ctype \
    php7.3-iconv \
    php7.3-tokenizer \
    php7.3-mbstring \
    php7.3-imap \
    php7.3-json \
    php7.3-xml \
    php7.3-simplexml \
    php7.3-xmlwriter \
    php7.3-xmlrpc \
    php7.3-xsl \
    php7.3-zip \
    php7.3-bz2 \
    php7.3-posix \
    php7.3-intl \
    php7.3-pdo \
    php7.3-mysql \
    php7.3-pgsql \
    php7.3-sqlite3 \
    php7.3-soap \
    php7.3-gd \
    php7.3-gmp \
    php7.3-ldap \
    php7.3-bcmath \
    php7.3-geoip \
    php7.3-gmagick \
    php7.3-xdebug \
    && apt-get autoremove -y \
    && apt-get clean

RUN mkdir -p /run/php/ && \
    touch /run/php/php7.3-fpm.pid && \
    chown $USER_ID:www-data /run/php/php7.3-fpm.pid

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

CMD ["php-fpm7.3", "-F"]
EXPOSE 9000 9001 9003