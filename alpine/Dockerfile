FROM alpine:3.7 as installer

# Install dependencies
RUN apk add --no-cache gawk unzip

ARG XLR_VERSION
ENV APP_ROOT=/opt
ENV APP_HOME=/opt/xl-release-server

# Install XL Release
ADD resources/xl-release-${XLR_VERSION}-server.zip /tmp
RUN mkdir -p ${APP_ROOT} && \
    unzip /tmp/xl-release-${XLR_VERSION}-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-release-${XLR_VERSION}-server ${APP_HOME}

# Add bin/run-in-container.sh
ADD resources/bin/run-in-container.sh ${APP_HOME}/bin/

# Modify bin/run.sh so that java becomes a child process of dumb-init
RUN sed -i 's/^\($JAVACMD $XL_RELEASE_SERVER_OPTS\)/exec \1/' ${APP_HOME}/bin/run.sh

# Move and augment conf directory of regular install
RUN mv ${APP_HOME}/conf ${APP_HOME}/default-conf && \
    mkdir ${APP_HOME}/conf
COPY resources/default-conf ${APP_HOME}/default-conf

# Modify conf/xlr-wrapper-linux.conf to add node-conf to the classpath and to add container-specific VM options
RUN gawk -i inplace '/^wrapper.java.classpath.1=/ { print "wrapper.java.classpath.1=node-conf" } \
{ if (match($0, /^(wrapper.java.classpath).([0-9]+)=(.*)$/, a)) { printf("%s.%d=%s\n", a[1], (a[2]+1), a[3]) } else \
  if (/^wrapper.java.additional.1=-Xms1024m$/) { print "wrapper.java.additional.1=-XX:+UnlockExperimentalVMOptions" } else \
  if (/^wrapper.java.additional.2=-Xmx4096m$/) { print "wrapper.java.additional.2=-XX:+UseCGroupMemoryLimitForHeap" } else \
  { print $0 }}' ${APP_HOME}/default-conf/xlr-wrapper-linux.conf

# Create node-specific conf directory and add template for node-specific xl-release.conf file
RUN mkdir ${APP_HOME}/node-conf
ADD resources/node-conf/xl-release.conf.template ${APP_HOME}/node-conf

# Move plugins directory
RUN mv ${APP_HOME}/plugins ${APP_HOME}/default-plugins && \
    mkdir ${APP_HOME}/plugins

# Create empty archive and repository directories
RUN mkdir ${APP_HOME}/archive ${APP_HOME}/repository

# Set permissions
RUN chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    chmod g+x ${APP_HOME}/bin/*.sh

FROM openjdk:8-jdk-alpine
MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-release" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="8.1.0" \
      release="1" \
      summary="XL Release" \
      description="Automate, orchestrate and get visibility into your release pipelines — at enterprise scale" \
      url="https://www.xebialabs.com/xl-release"

# Install dependencies
RUN apk add --no-cache dumb-init pwgen

ENV USER_NAME=xl-release USER_UID=10001 APP_ROOT=/opt
ENV APP_HOME=/opt/xl-release-server

# Copy installed XL Release
COPY --from=installer ${APP_ROOT} ${APP_ROOT}

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

VOLUME ["${APP_HOME}/archive", "${APP_HOME}/conf", "${APP_HOME}/hotfix", "${APP_HOME}/ext", "${APP_HOME}/plugins", "${APP_HOME}/repository"]
EXPOSE 5516

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in dumb-init running with a PID higher than 1.
ENTRYPOINT ["/usr/bin/dumb-init", "/opt/xl-release-server/bin/run-in-container.sh"]
