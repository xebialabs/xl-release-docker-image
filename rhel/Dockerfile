FROM registry.access.redhat.com/rhel7/rhel-atomic
MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-release" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="8.1.0" \
      release="1" \
      summary="XL Release" \
      description="Release orchestration" \
      url="https://www.xebialabs.com/xl-release"

ARG XLR_VERSION
ENV APP_ROOT=/opt USER_NAME=xl-deploy USER_UID=10001
ENV APP_HOME=${APP_ROOT}/xl-release-server

COPY resources/tini /tini
RUN chmod ugo+x /tini

COPY resources/help.md /tmp/

### add licenses to this directory
COPY resources/licenses /licenses

# Install dependencies
RUN INSTALL_PKGS="golang-github-cpuguy83-go-md2man curl hostname" && \
    microdnf install --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-optional-rpms --nodocs ${INSTALL_PKGS} && \
    microdnf update && \
### help file markdown to man conversion
    go-md2man -in /tmp/help.md -out /help.1 && \
    microdnf clean all

RUN microdnf install --enablerepo=rhel-7-server-rpms --nodocs unzip gawk java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
### Set the Java random source
    echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/java/jre/lib/security/java.security && \
    microdnf clean all

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
RUN gawk '/^wrapper.java.classpath.1=/ { print "wrapper.java.classpath.1=node-conf" } \
{ if (match($0, /^(wrapper.java.classpath).([0-9]+)=(.*)$/, a)) { printf("%s.%d=%s\n", a[1], (a[2]+1), a[3]) } else \
  if (/^wrapper.java.additional.1=-Xms1024m$/) { print "wrapper.java.additional.1=-XX:+UnlockExperimentalVMOptions" } else \
  if (/^wrapper.java.additional.2=-Xmx4096m$/) { print "wrapper.java.additional.2=-XX:+UseCGroupMemoryLimitForHeap" } else \
  { print $0 }}' ${APP_HOME}/default-conf/xlr-wrapper-linux.conf > /tmp/xlr-wrapper-linux.conf
RUN mv /tmp/xlr-wrapper-linux.conf ${APP_HOME}/default-conf/xlr-wrapper-linux.conf

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

WORKDIR ${APP_HOME}

# Don't run as root
USER 10001

VOLUME ["${APP_HOME}/conf", "${APP_HOME}/hotfix/lib", "${APP_HOME}/hotfix/plugins", "${APP_HOME}/ext", "${APP_HOME}/plugins", "${APP_HOME}/repository"]
EXPOSE 4516

# Environment variables are not expanded when using the exec form of the ENTRYPOINT command. They are
# expanded when using the shell form, but that results in dumb-init running with a PID higher than 1.
ENTRYPOINT ["/tini", "/opt/xl-release-server/bin/run-in-container.sh"]
