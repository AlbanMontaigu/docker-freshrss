# ================================================================================================================
#
# FreshRSS with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php/blob/master/Dockerfile
# @see https://github.com/AlbanMontaigu/docker-freshrss
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# FreshRSS env variables
ENV FRESHRSS_VERSION="1.1.1"

# System update & install the PHP extensions we need
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd

# Get FreshRSS and install it
RUN mkdir -p --mode=777 /var/local/backup/freshrss \
    && mkdir -p --mode=777 /usr/src/freshrss \
    && curl -o freshrss.tgz -SL https://github.com/FreshRSS/FreshRSS/archive/$FRESHRSS_VERSION.tar.gz \
    && tar -xzf freshrss.tgz --strip-components=1 -C /usr/src/freshrss \
        --exclude=CHANGELOG.md \
        --exclude=CONTRIBUTING.md \
        --exclude=CREDITS.md \
        --exclude=README.fr.md \
        --exclude=README.md \
        --exclude=LICENSE \
        --exclude=tests \
    && rm freshrss.tgz \
    && chown -R nginx:nginx /usr/src/freshrss

# NGINX tuning for SHAARLI
COPY ./nginx/conf/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Volume for freshrss backup
VOLUME /var/local/backup/freshrss

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
