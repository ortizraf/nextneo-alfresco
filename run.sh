#!/bin/sh

export COMPOSE_FILE_PATH="${PWD}/docker/docker-compose.yml"
ENVIRONMENT="${2:-dev}"
ENV_FILE="${PWD}/.env.${ENVIRONMENT}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Environment file not found: $ENV_FILE" >&2
  echo "Usage: $0 {build_start|start|stop|purge|tail|reload_share|reload_acs|build_test|test} [dev|hml|prod]" >&2
  exit 1
fi

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

start() {
    compose up --build -d
}

compose() {
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE_PATH" "$@"
}

start_share() {
    compose up --build -d alfresco-share
}

start_acs() {
    compose up --build -d alfresco-acs
}

down() {
    if [ -f "$COMPOSE_FILE_PATH" ]; then
        compose down
    fi
}

purge() {
    compose down --volumes
}

build() {
    $MVN_EXEC clean package
}

build_share() {
    compose kill alfresco-share
    yes | compose rm -f alfresco-share
    $MVN_EXEC clean package -pl alfresco-share,alfresco-share-docker
}

build_acs() {
    compose kill alfresco-acs
    yes | compose rm -f alfresco-acs
    $MVN_EXEC clean package -pl alfresco-integration-tests,alfresco-platform,alfresco-platform-docker
}

tail() {
    compose logs -f
}

tail_all() {
    compose logs --tail="all"
}

prepare_test() {
    $MVN_EXEC verify -DskipTests=true -pl alfresco-platform,alfresco-integration-tests,alfresco-platform-docker
}

test() {
    $MVN_EXEC verify -pl alfresco-platform,alfresco-integration-tests
}

case "$1" in
  build_start)
    down
    build
    start
    tail
    ;;
  build_start_it_supported)
    down
    build
    prepare_test
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  reload_share)
    build_share
    start_share
    tail
    ;;
  reload_acs)
    build_acs
    start_acs
    tail
    ;;
  build_test)
    down
    build
    prepare_test
    start
    test
    tail_all
    down
    ;;
  test)
    test
    ;;
  *)
    echo "Usage: $0 {build_start|build_start_it_supported|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
esac
