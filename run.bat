@ECHO OFF

SET COMPOSE_FILE_PATH=%CD%\docker\docker-compose.yml
SET ENVIRONMENT=%2
IF [%ENVIRONMENT%]==[] SET ENVIRONMENT=dev
SET ENV_FILE=%CD%\.env.%ENVIRONMENT%
IF NOT EXIST "%ENV_FILE%" (
    echo Environment file not found: %ENV_FILE%
    echo Usage: %0 {build_start^|build_start_it_supported^|start^|stop^|purge^|tail^|reload_share^|reload_acs^|build_test^|test} [dev^|hml^|prod]
    GOTO END
)

IF [%M2_HOME%]==[] (
    SET MVN_EXEC=mvn
)

IF NOT [%M2_HOME%]==[] (
    SET MVN_EXEC=%M2_HOME%\bin\mvn
)

IF [%1]==[] (
    echo "Usage: %0 {build_start|build_start_it_supported|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
    GOTO END
)

IF %1==build_start (
    CALL :down
    CALL :build
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==build_start_it_supported (
    CALL :down
    CALL :build
    CALL :prepare-test
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==start (
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==stop (
    CALL :down
    GOTO END
)
IF %1==purge (
    CALL:down
    CALL:purge
    GOTO END
)
IF %1==tail (
    CALL :tail
    GOTO END
)
IF %1==reload_share (
    CALL :build_share
    CALL :start_share
    CALL :tail
    GOTO END
)
IF %1==reload_acs (
    CALL :build_acs
    CALL :start_acs
    CALL :tail
    GOTO END
)
IF %1==build_test (
    CALL :down
    CALL :build
    CALL :prepare-test
    CALL :start
    CALL :test
    CALL :tail_all
    CALL :down
    GOTO END
)
IF %1==test (
    CALL :test
    GOTO END
)
echo "Usage: %0 {build_start|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
:END
EXIT /B %ERRORLEVEL%

:start
    CALL :compose up --build -d
EXIT /B 0
:start_share
    CALL :compose up --build -d alfresco-share
EXIT /B 0
:start_acs
    CALL :compose up --build -d alfresco-acs
EXIT /B 0
:down
    if exist "%COMPOSE_FILE_PATH%" (
        CALL :compose down
    )
EXIT /B 0
:build
	call %MVN_EXEC% clean package
EXIT /B 0
:build_share
    CALL :compose kill alfresco-share
    CALL :compose rm -f alfresco-share
	call %MVN_EXEC% clean package -pl alfresco-share,alfresco-share-docker
EXIT /B 0
:build_acs
    CALL :compose kill alfresco-acs
    CALL :compose rm -f alfresco-acs
	call %MVN_EXEC% clean package -pl alfresco-integration-tests,alfresco-platform,alfresco-platform-docker
EXIT /B 0
:tail
    CALL :compose logs -f
EXIT /B 0
:tail_all
    CALL :compose logs --tail="all"
EXIT /B 0
:prepare-test
    call %MVN_EXEC% verify -DskipTests=true -pl alfresco-platform,alfresco-integration-tests,alfresco-platform-docker
EXIT /B 0
:test
    call %MVN_EXEC% verify -pl alfresco-platform,alfresco-integration-tests
EXIT /B 0
:purge
    CALL :compose down --volumes
EXIT /B 0
:compose
    docker compose --env-file "%ENV_FILE%" -f "%COMPOSE_FILE_PATH%" %*
EXIT /B %ERRORLEVEL%
