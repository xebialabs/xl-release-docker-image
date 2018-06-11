#!/bin/sh

# Set up new installation
if [ ! -f "${APP_HOME}/conf/xl-release-server.conf" ]; then
  echo "Copying provided configuration"
  cp -r ${APP_HOME}/provided-conf/* ${APP_HOME}/conf/

  if [ "${ADMIN_PASSWORD}" == "" ]; then
    ADMIN_PASSWORD=`pwgen 8 1`
    echo "Generated admin password: ${ADMIN_PASSWORD}"
  fi
  echo "admin.password=${ADMIN_PASSWORD}" >> ${APP_HOME}/conf/xl-release-server.conf

  if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" == "" ]; then
    REPOSITORY_KEYSTORE_PASSPHRASE=`pwgen 16 1`
    echo "Generated repository keystore passphrase: ${REPOSITORY_KEYSTORE_PASSPHRASE}"
    echo "repository.keystore.password=${REPOSITORY_KEYSTORE_PASSPHRASE}" >> ${APP_HOME}/conf/xl-release-server.conf
  fi
  echo "Generating repository keystore"
  keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

  echo "Copying provided plugins"
  cp -r ${APP_HOME}/provided-plugins/* ${APP_HOME}/plugins/
fi

# Generate node specific configuration with IP address of container
IP_ADDRESS=$(hostname -i)
sed -e "s/\${IP_ADDRESS}/${IP_ADDRESS}/g" ${APP_HOME}/node-conf/xl-release.conf.template > ${APP_HOME}/node-conf/xl-release.conf

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"
