FROM alpine:edge
MAINTAINER Sebastian Knoth

# Add testing repo to get latest apk packages
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN echo "ipv6" >> /etc/modules

## Add basic stuff
RUN apk add --update --no-cache curl bash

# Add NGINX-Webserver with NAXSI
RUN apk upgrade -U && \
    apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    nginx

# Add PHP 7
RUN apk upgrade -U && \
    apk --update --repository=http://dl-4.alpinelinux.org/alpine/edge/testing add \
    php7 \
    php7-xml \
    php7-xsl \
    php7-pdo_mysql \
    php7-mcrypt \
    php7-curl \
    php7-json \
    php7-fpm \
    php7-phar \
    php7-openssl \
    php7-mysqli \
    php7-ctype \
    php7-mbstring

COPY .docker/alpine-php7-nginx/rootfs /

# Small fixes
RUN ln -s /etc/php7 /etc/php && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/sbin/php-fpm7 /usr/bin/php-fpm && \
    ln -s /usr/lib/php7 /usr/lib/php && \
    rm -fr /var/cache/apk/*

# Add S6-overlay to use S6 process manager
# https://github.com/just-containers/s6-overlay/#the-docker-way
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.17.2.0/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Install composer global bin
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

# ADD SOURCE
ONBUILD RUN chown -Rf nginx:nginx /usr/share/nginx/html/

# Expose Ports
EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/init"]