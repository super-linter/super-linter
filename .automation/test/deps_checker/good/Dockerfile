FROM docker.localhost:8080/repo/python:3.7-slim as build-image

RUN apk add --no-cache \
    git git-lfs \
    make \
    zlib zlib-dev

# Known issue -- this pulls from DockerHub and should fail, but currently passes.
FROM python:3.7-alpine as run-image

COPY --from=build-image /usr/bin/ /usr/bin/

