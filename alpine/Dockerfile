FROM alpine:3.7 as installer

# Install dependencies
RUN apk -U upgrade && apk add unzip

ARG XLR_VERSION
ENV APP_ROOT=/opt
ENV APP_HOME=/opt/xl-release-server

# Install XLR
COPY resources/xl-release-${XLR_VERSION}-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-release-${XLR_VERSION}-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-release-${XLR_VERSION}-server ${APP_HOME}

# Augment bin directory of regular install
COPY resources/bin/*.sh ${APP_HOME}/bin/

# Move and augment conf directory of regular install
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf

# Create and populate node-specific conf directory
RUN mkdir ${APP_HOME}/node-conf
COPY resources/node-conf ${APP_HOME}/node-conf

# Move plugins directory
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins

# Create empty repository directory
RUN mkdir ${APP_HOME}/repository

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh

FROM openjdk:8-jdk-alpine
MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-release" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="8.0.1" \
      release="1" \
      summary="XL Release" \
      description="Automate, orchestrate and get visibility into your release pipelines — at enterprise scale" \
      url="https://www.xebialabs.com/xl-release"

# Install dependencies
RUN apk add --no-cache dumb-init pwgen

ENV USER_NAME=xl-release USER_UID=10001 APP_ROOT=/opt
ENV APP_HOME=/opt/xl-release-server

# Copy installed XLR
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

VOLUME ["${APP_HOME}/hotfix"]
VOLUME ["${APP_HOME}/node-conf", "${APP_HOME}/conf"]
VOLUME ["${APP_HOME}/ext", "${APP_HOME}/plugins"]
VOLUME ["${APP_HOME}/repository", "${APP_HOME}/archive"]
EXPOSE 5516

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in dumb-init running with a PID higher than 1.
ENTRYPOINT ["/usr/bin/dumb-init", "/opt/xl-release-server/bin/run-in-container.sh"]
