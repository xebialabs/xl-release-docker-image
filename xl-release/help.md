% XL-RELEASE (1) Container Image Pages
% Jeroen van Erp
% April 10, 2018

# NAME
xl-release \- Automate, orchestrate and get visibility into your release pipelinee - at enterprise scale

# DESCRIPTION
XebiaLabs develops enterprise-scale Continuous Delivery and DevOps software, providing companies with the visibility, automation and control to deliver software faster and with less risk.

The XL Release product specifically is designed to help users orchestrate complex release pipelines with ease. Some of its key features are:


- Plan, automate, and analyze the entire software release pipeline
- Control and optimize software delivery
- Always know the status of automated and manual steps across the release pipeline
- Identify bottlenecks, reduce errors, and lower the risk of release failures

# ENVIRONMENT VARIABLES
The following environment variables can be set to configure the image for different scenarios

APP_ROOT=/opt/xl-release
    This environment variable is used as the landing point for all the application data.

DATA_DIR=${APP_ROOT}/xlr-data
    This environment variable is used as the volume name for the persistent data of the embedded database. **Always ensure that this directory is a subdirectory of the APP_ROOT variable**.

BOOTSTRAP_DIR=${APP_ROOT}/xlr-bootstrap
    In case on non-ephemeral containers, this environment variable is used at the volume name for the bootstrap configuration files that are shared between containers. **Always ensure that this directory is a subdirectory of the APP_ROOT variable**.

XLR_CLUSTER_MODE=default
    The clustering mode in which XL Release will run, choose one from `default`, `hot-standby` or `full`.

XLR_DB_TYPE=h2
    The type of database that XL Release will connect to, default is to use `h2` embedded running on a volume to persist it's data. Other supported databases are `mysql`, `postgres` and `mssql`.

XLR_REPO_DB_URL=jdbc:h2:file:${DATA_DIR}/xlr-repo
    The JDBC URL to connect to the "repository" database. The default h2 one uses the data volume defined by the `DATA_DIR` environment variable to persist it's data

XLR_REPO_DB_USERNAME=sa
    The JDBC username used to connect to the "repository" database.

XLR_REPO_DB_PASSWORD=123
    The JDBC password used to connect to the "repository" database.

XLR_ARCHIVE_DB_URL=jdbc:h2:file:${DATA_DIR}/xlr-archive
    The JDBC URL to connect to the "archive" database. The default h2 one uses the data volume defined by the `DATA_DIR` environment varialbe to persist it's data

XLR_ARCHIVE_DB_USERNAME=sa
    The JDBC username used to connect to the "archive" database.

XLR_ARCHIVE_DB_PASSWORD=123
    The JDBC password used to connect to the "archive" database.
