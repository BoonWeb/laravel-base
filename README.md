# laravel-base

Base image for production ready laravel projects.

This image contains PHP and NGINX already configured to serve a laravel applicatino from `/app` folder.

## Build image

```bash
export CONTAINER_IMAGE=boonweb/laravel-base
export BUILD_VERSION=1.0.0
export CI_COMMIT_SHORT_SHA=d3ed58b0fe

DOCKER_BUILDKIT=1 \
docker build \
    --no-cache \
    --pull \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg BUILD_VERSION=${BUILD_VERSION} \
    --build-arg VCS_REF=${CI_COMMIT_SHORT_SHA} \
    --tag ${CONTAINER_IMAGE}:${BUILD_VERSION} \
    --tag ${CONTAINER_IMAGE}:latest \
    --file "Dockerfile" .
```

## How to use in your own project

Create a Dockerfile with following contents inside your project and run `docker build`:

```Dockerfile
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

FROM docker.io/boonweb/laravel-base:latest

ENV PATH=/app/vendor/bin:$PATH

COPY --chown=www-user . /app
COPY --chown=www-user --from=vendor /app/vendor ./vendor

RUN composer dump-autoload && \
    php artisan optimize --ansi --no-interaction && \
    php artisan package:discover --ansi --no-interaction && \
    php artisan storage:link --ansi --no-interaction
```

> You might want to add a build step to install yarn/npm packages and copy them to the final image.
