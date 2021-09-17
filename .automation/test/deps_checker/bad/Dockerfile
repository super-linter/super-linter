FROM python:3.7-slim as build-image

RUN apk add --no-cache \
    git git-lfs \
    make \
    zlib zlib-dev

FROM python:3.7-alpine as run-image

COPY --from=build-image /usr/bin/ /usr/bin/

