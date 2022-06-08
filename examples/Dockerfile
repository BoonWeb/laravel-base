# --- STAGE VENDOR
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json /app/composer.json
COPY composer.lock /app/composer.lock

RUN composer install \
    --optimize-autoloader \
    --no-dev \
    --no-scripts \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins

# --- JS/CSS ASSETS
FROM node:16 as assets
WORKDIR /app
RUN mkdir -p /app/public
COPY package.json webpack.*.js tailwind.*.js yarn.lock /app/
COPY resources/ /app/resources/
RUN yarn install && yarn production

# --- FINAL IMAGE
FROM docker.io/boonweb/laravel-base:latest
LABEL maintainer="info@boonweb.de"

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

ENV PATH=/app/vendor/bin:$PATH

LABEL org.opencontainers.image.title="boonweb/laravel-base"
LABEL org.opencontainers.image.description="Laravel base image with PHP 8.1 and nginx"
LABEL org.opencontainers.image.vendor="BoonWeb GmbH"
LABEL org.opencontainers.image.authors="Christoph René Pardon"
LABEL org.opencontainers.image.url="https://boonweb.de"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.version=$BUILD_VERSION
LABEL org.opencontainers.image.revision=$VCS_REF

COPY --chown=www-user . /app
COPY --chown=www-user --from=vendor /app/vendor ./vendor
COPY --chown=www-user --from=assets /app/public/js/ /app/public/js/
COPY --chown=www-user --from=assets /app/public/css/ /app/public/css/
COPY --chown=www-user --from=assets /app/mix-manifest.json /app/mix-manifest.json

RUN composer dump-autoload && \
    php artisan optimize --ansi --no-interaction && \
    php artisan package:discover --ansi --no-interaction && \
    php artisan storage:link --ansi --no-interaction
