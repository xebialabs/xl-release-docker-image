FROM openjdk:8-jdk
MAINTAINER XebiaLabs Development <docker@xebialabs.com>

LABEL name="xebialabs/xl-release" \
      maintainer="docker@xebialabs.com" \
      vendor="XebiaLabs" \
      version="7.5.3" \
      release="1" \
      summary="XL Release" \
      description="Release orchestration" \
### Required labels above - recommended below
      url="https://www.xebialabs.com/xl-release"
      # run='docker run -tdi --name ${NAME} ${IMAGE}' \
      # io.k8s.description="Starter app will do ....." \
      # io.k8s.display-name="Starter app" \
      # io.openshift.expose-services="" \
      # io.openshift.tags="acme,starter"

COPY help.md /tmp/

### add licenses to this directory
COPY licenses /licenses

# Install XLR
ARG XLR_VERSION
ENV JAVA_HOME=/usr USER_NAME=xl-release USER_UID=10001 APP_ROOT=/opt/xl-release
ENV APP_HOME=${APP_ROOT}/xlr-server BOOTSTRAP_DIR=${APP_ROOT}/xlr-bootstrap DATA_DIR=${APP_ROOT}/xlr-data

RUN mkdir ${APP_ROOT}

COPY xl-release-${XLR_VERSION}-server.zip ${APP_ROOT}
COPY conf-templates /tmp/templates
RUN unzip ${APP_ROOT}/xl-release-${XLR_VERSION}-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-release-${XLR_VERSION}-server ${APP_HOME} && \
    mkdir ${BOOTSTRAP_DIR} && \
    mkdir ${DATA_DIR} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} && \
    rm ${APP_ROOT}/xl-release-${XLR_VERSION}-server.zip
COPY bin/xlr-bootstrapper.sh ${APP_HOME}
RUN chmod g+x ${APP_HOME}/xlr-bootstrapper.sh && \
    chgrp 0 ${APP_HOME}/xlr-bootstrapper.sh

# Don't run as root
USER 10001
WORKDIR ${APP_HOME}

# plugins, hotfix, ext and conf will be copied from the /xlr-bootstrap by the bootstrapper into the installation
# repository and archive will be the persistent data layer for the standalone version of XLR
VOLUME ${BOOTSTRAP_DIR} ${DATA_DIR}

ENV XLR_CLUSTER_MODE default
ENV XLR_DB_TYPE h2
ENV XLR_REPO_DB_URL jdbc:h2:file:${DATA_DIR}/xlr-repo
ENV XLR_REPO_DB_USERNAME sa
ENV XLR_REPO_DB_PASSWORD 123
ENV XLR_ARCHIVE_DB_URL jdbc:h2:file:${DATA_DIR}/xlr-archive
ENV XLR_ARCHIVE_DB_USERNAME sa
ENV XLR_ARCHIVE_DB_PASSWORD 123
ENV XLR_METRICS_ENABLED false

EXPOSE 5516
ENTRYPOINT ${APP_HOME}/xlr-bootstrapper.sh
