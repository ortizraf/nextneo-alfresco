# Alfresco AIO Project - SDK 4.16.0

This is an All-In-One (AIO) project for Alfresco SDK 4.16.0.

Run with `./run.sh build_start` or `./run.bat build_start` and verify that it

 * Runs Alfresco Content Service (ACS)
 * Runs Alfresco Share
 * Runs Alfresco Search Service (ASS)
 * Runs MariaDB database
 * Deploys the JAR assembled modules
 
All the services of the project are now run as docker containers. The run script offers the next tasks:

## Environment configuration

The repository includes `.env.dev`, `.env.hml`, and `.env.prod` with simulated values so each environment can be started independently. These values are for local demonstration only and must never be used for real systems. For real systems, inject credentials outside Git through exported environment variables or your deployment's secret manager.

The default environment is `dev`. Select another environment as the second argument, for example `./run.sh start hml` or `./run.sh build_start prod`. Each environment has a distinct Compose project name, so Docker creates separate containers, networks, and persistent volumes.

The repository database runs on MariaDB. Its host port is configured with `MARIADB_PORT` in the selected `.env` file; the container listens on port `3306`.

## Testar a configuração MariaDB

If this environment was previously started with PostgreSQL, reset its Compose volumes before the first MariaDB start. This removes the database, Alfresco content, and search data for that environment:

```sh
./run.sh purge dev
```

Build the project and start the services:

```sh
./run.sh build_start
```

The script follows the container logs; press `Ctrl+C` to stop following them. Containers keep running. In another terminal, check that all services are running and query the MariaDB version:

```sh
docker compose --env-file .env.dev -f docker/docker-compose.yml ps
docker compose --env-file .env.dev -f docker/docker-compose.yml exec alfresco-mariadb mariadb -u alfresco -p alfresco -e "SELECT VERSION(), DATABASE();"
```

Enter the `MARIADB_PASSWORD` value from `.env.dev` when prompted. Then open `http://localhost:9999/share/` and sign in to confirm Share can reach the Repository. To stop the environment while preserving its data, run `./run.sh stop dev`.

The Nginx proxy is available on port `9999` in all environments. Run only one environment at a time on the same machine because they share this host port. Opening the proxy root redirects to Share (`/share/`); Repository APIs are available under `/alfresco/`. Alfresco handles the login; Nginx forwards the requests and cookies. Direct ACS and Share ports remain mapped for development and integration tests.

`./run.sh purge <environment>` permanently removes that environment's Compose volumes, including its database and Alfresco content data.

The environment files and Docker Compose configuration are development templates. They do not provide an Enterprise Repository cluster or make Community suitable for active-active Repository nodes.

 * `build_start`. Build the whole project, recreate the ACS and Share docker images, start the dockerised environment composed by ACS, Share, ASS and 
 MariaDB and tail the logs of all the containers.
 * `build_start_it_supported`. Build the whole project including dependencies required for IT execution, recreate the ACS and Share docker images, start the 
 dockerised environment composed by ACS, Share, ASS and MariaDB and tail the logs of all the containers.
 * `start`. Start the dockerised environment without building the project and tail the logs of all the containers.
 * `stop`. Stop the dockerised environment.
 * `purge`. Stop the dockerised container and delete all the persistent data (docker volumes).
 * `tail`. Tail the logs of all the containers.
 * `reload_share`. Build the Share module, recreate the Share docker image and restart the Share container.
 * `reload_acs`. Build the ACS module, recreate the ACS docker image and restart the ACS container.
 * `build_test`. Build the whole project, recreate the ACS and Share docker images, start the dockerised environment, execute the integration tests from the
 `integration-tests` module and stop the environment.
 * `test`. Execute the integration tests (the environment must be already started).

# Few things to notice

 * No parent pom
 * No WAR projects, the jars are included in the custom docker images
 * No runner project - the Alfresco environment is now managed through [Docker](https://www.docker.com/)
 * Standard JAR packaging and layout
 * Works seamlessly with Eclipse and IntelliJ IDEA
 * JRebel for hot reloading, JRebel maven plugin for generating rebel.xml [JRebel integration documentation]
 * AMP as an assembly
 * Persistent test data through restart thanks to the use of Docker volumes for ACS, ASS and database data
 * Integration tests module to execute tests against the final environment (dockerised)
 * Resources loaded from META-INF
 * Web Fragment (this includes a sample servlet configured via web fragment)

# TODO

  * Abstract assembly into a dependency so we don't have to ship the assembly in the archetype
  * Functional/remote unit tests
