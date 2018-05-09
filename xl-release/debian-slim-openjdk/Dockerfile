FROM buildpack-deps:stretch-scm as installer

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		unzip go-md2man \
	&& rm -rf /var/lib/apt/lists/*

ARG XLR_VERSION
ENV APP_ROOT=/opt/xl-release
ENV APP_HOME=${APP_ROOT}/xlr-server BOOTSTRAP_DIR=${APP_ROOT}/xlr-bootstrap DATA_DIR=${APP_ROOT}/xlr-data

# Install XLR
COPY xl-release-${XLR_VERSION}-server.zip /tmp
RUN mkdir ${APP_ROOT} && \
    unzip /tmp/xl-release-${XLR_VERSION}-server.zip -d ${APP_ROOT} && \
    mv ${APP_ROOT}/xl-release-${XLR_VERSION}-server ${APP_HOME} && \
    mkdir ${BOOTSTRAP_DIR} && \
    mkdir ${DATA_DIR} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

# Add bootstrapper script
COPY bin/xlr-bootstrapper.sh ${APP_HOME}
RUN chmod g+x ${APP_HOME}/xlr-bootstrapper.sh && \
    chgrp 0 ${APP_HOME}/xlr-bootstrapper.sh

# Install man page
COPY help.md /tmp
RUN go-md2man -in /tmp/help.md -out /help.1

FROM openjdk:8-jdk-alpine
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

# Copy installed XLR
ENV USER_NAME=xl-release USER_UID=10001 APP_ROOT=/opt/xl-release
ENV APP_HOME=${APP_ROOT}/xlr-server BOOTSTRAP_DIR=${APP_ROOT}/xlr-bootstrap DATA_DIR=${APP_ROOT}/xlr-data

COPY --from=installer ${APP_ROOT} ${APP_ROOT}

# Copy installed man page
COPY --from=installer /help.1 /help.1

# Copy configuration templates
COPY conf-templates /tmp/templates

# Install bash (for bootstrapper script)
RUN apk -U upgrade && apk add bash

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
ENV XLR_DEVELOPMENT_MODE false

EXPOSE 5516
ENTRYPOINT ${APP_HOME}/xlr-bootstrapper.sh
