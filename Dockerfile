FROM ubuntu:22.04
LABEL maintainer="info@boonweb.de"

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION
ARG WWWGROUP

LABEL org.opencontainers.image.title="boonweb/laravel-base"
LABEL org.opencontainers.image.description="PHP Base image for laravel projects"
LABEL org.opencontainers.image.source="https://github.com/BoonWeb/laravel-base-php81"
LABEL org.opencontainers.image.vendor="BoonWeb GmbH"
LABEL org.opencontainers.image.authors="Christoph René Pardon"
LABEL org.opencontainers.image.url="https://boonweb.de"
LABEL org.opencontainers.image.documentation="https://boonweb.com"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.version=$BUILD_VERSION
LABEL org.opencontainers.image.revision=$VCS_REF

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
ENV PATH=/app/vendor/bin:$PATH
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV WWWGROUP=${WWWGROUP:-1000}
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 8080
ENTRYPOINT ["start-container"]
CMD ["/usr/bin/sudo", "/usr/sbin/php-fpm8.1", "-F", "-c", "/etc/php/8.1/fpm/php-fpm.conf"]

RUN apt-get update \
    && apt-get install -y gnupg curl ca-certificates zip unzip git libcap2-bin libpng-dev python3 nginx sudo figlet \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
    && echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.1-cli php8.1-fpm \
       php8.1-pgsql php8.1-gd \
       php8.1-curl php8.1-opcache \
       php8.1-imap php8.1-mysql php8.1-mbstring \
       php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
       php8.1-intl php8.1-readline \
       php8.1-ldap \
       php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
       php8.1-memcached \
       nodejs npm \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get update \
    && npm i -g yarn \
    && apt-get install -y mariadb-client \
#    && apt-get install -y postgresql-client-$POSTGRES_VERSION \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --force -g $WWWGROUP www-group
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1000 www-user

RUN mkdir -p /home/www-user/nginx/logs /var/cache/nginx /var/log/nginx \
    && mv /etc/nginx/* /home/www-user/nginx/ \
    && touch /home/www-user/nginx/logs/access.log \
    && touch /home/www-user/nginx/logs/error.log \
    && chown -R www-user:www-group /home/www-user \
    && chown -R www-user:www-group /var/log

COPY ./assets/start-container /usr/local/bin/start-container
COPY ./assets/php/php.ini /etc/php/8.1/cli/conf.d/99-custom.ini
COPY ./assets/php/php.ini /etc/php/8.1/fpm/conf.d/99-custom.ini
COPY ./assets/php/fpm/www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY --chown=www-user ./assets/nginx/nginx.conf /home/www-user/nginx/nginx.conf
COPY --chown=www-user ./assets/nginx/site.conf /home/www-user/nginx/conf.d/default.conf

RUN chmod +x /usr/local/bin/start-container \
 && chown -R www-user:0 /var/cache/nginx \
 && chmod -R g+w /var/cache/nginx \
 && chown -R www-user:0 /var/lib/nginx \
 && chmod -R 755 /var/lib/nginx \
 && touch /var/run/nginx.pid \
 && chown -R www-user:0 /var/run/nginx.pid \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && chown -R www-user:0 /var/log/nginx \
 && chmod -R 755 /var/log/nginx \
 && chown -R www-user:www-group /app

RUN cat /etc/sudoers
COPY ./assets/sudoers /etc/sudoers

USER www-user
