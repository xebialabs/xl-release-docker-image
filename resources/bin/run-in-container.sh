#!/bin/sh

# Set up new installation
if [ ! -f "${APP_HOME}/conf/xl-release-server.conf" ]; then
  echo "Setting up new installation of XL Release"
  echo "... Copying default configuration"
  cd ${APP_HOME}/default-conf
  for f in *; do
    if [ -f ${APP_HOME}/conf/$f ]; then
      echo "...... Not copying $f because it already exists in the conf directory"
    else
      cp -R $f ${APP_HOME}/conf/
    fi
  done
  cd ${APP_HOME}

  if [ "${ADMIN_PASSWORD}" == "" ]; then
    ADMIN_PASSWORD=`pwgen 8 1`
    echo "... Generated admin password: ${ADMIN_PASSWORD}"
  fi
  echo "admin.password=${ADMIN_PASSWORD}" >> ${APP_HOME}/conf/xl-release-server.conf

  if [ "${REPOSITORY_KEYSTORE_PASSPHRASE}" == "" ]; then
    REPOSITORY_KEYSTORE_PASSPHRASE=`pwgen 16 1`
    echo "... Generated repository keystore passphrase: ${REPOSITORY_KEYSTORE_PASSPHRASE}"
    echo "repository.keystore.password=${REPOSITORY_KEYSTORE_PASSPHRASE}" >> ${APP_HOME}/conf/xl-release-server.conf
  fi
  echo "... Generating repository keystore"
  keytool -genseckey -alias deployit-passsword-key -keyalg aes -keysize 128 -keypass "deployit" -keystore ${APP_HOME}/conf/repository-keystore.jceks -storetype jceks -storepass ${REPOSITORY_KEYSTORE_PASSPHRASE}

  echo "... Copying default plugins"
  cd ${APP_HOME}/default-plugins
  for pluginrepo in *; do
    if [ -d ${APP_HOME}/default-plugins/$pluginrepo ]; then
      mkdir -p ${APP_HOME}/plugins/$pluginrepo
      cd ${APP_HOME}/default-plugins/$pluginrepo
      for pluginjar in *; do
        pluginbasename=${pluginjar%%-[0-9\.]*.jar}
        if [ -f ${APP_HOME}/plugins/*/$pluginbasename-[0-9\.]*.jar ]; then
          echo "...... Not copying $pluginrepo/$pluginjar because a version of that plugin already exists in the plugins directory"
        else
          cp -R ${APP_HOME}/default-plugins/$pluginrepo/$pluginjar ${APP_HOME}/plugins/$pluginrepo/
        fi
      done
    else
      cp -R ${APP_HOME}/default-plugins/$pluginrepo ${APP_HOME}/plugins/
    fi
  done
  cd ${APP_HOME}

  echo "Done"
fi

# Generate node specific configuration with IP address of container
IP_ADDRESS=$(hostname -i)
sed -e "s/\${IP_ADDRESS}/${IP_ADDRESS}/g" ${APP_HOME}/node-conf/xl-release.conf.template > ${APP_HOME}/node-conf/xl-release.conf

# Start regular startup process
exec ${APP_HOME}/bin/run.sh "$@"
