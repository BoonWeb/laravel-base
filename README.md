![GitHub](https://img.shields.io/github/license/BoonWeb/laravel-base?style=plastic)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/boonweb/laravel-base?style=plastic)
# laravel-base

Base image for production ready laravel projects.

This image contains PHP and NGINX already configured to serve a laravel application from `/app` folder.

## Build image

```bash
export CONTAINER_IMAGE=boonweb/laravel-base
export BUILD_VERSION=1.0.3
export CI_COMMIT_SHORT_SHA=d3ed58b0fe

DOCKER_BUILDKIT=1 \
docker build \
    --no-cache \
    --pull \
    --platform linux/amd64,linux/arm64
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg BUILD_VERSION=${BUILD_VERSION} \
    --build-arg VCS_REF=${CI_COMMIT_SHORT_SHA} \
    --tag ${CONTAINER_IMAGE}:${BUILD_VERSION} \
    --tag ${CONTAINER_IMAGE}:latest \
    --file "Dockerfile" .
docker login -u boonweb
# > enter access token
docker push ${CONTAINER_IMAGE}:${BUILD_VERSION}
docker push ${CONTAINER_IMAGE}:latest
```

## How to use in your own project

See `examples/` folder to get an idea on how to use this base image.
