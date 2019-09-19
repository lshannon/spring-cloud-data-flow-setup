cf delete skipper-luke -f
cf delete-service postgres_skipper -f
cf create-service elephantsql turtle postgres_skipper
cf push skipper-luke --no-start -b java_buildpack -m 1G -k 2G --no-start -p skipper/spring-cloud-skipper-server-1.1.3.BUILD-SNAPSHOT.jar
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX true
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_DOMAIN cfapps.io
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SKIP_SSL_VALIDATION false
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_PASSWORD pcf*source
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_USERNAME luke.shannon@gmail.com
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SPACE development
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_ORG scdf-book
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_URL https://api.run.pivotal.io
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_STRATEGIES_HEALTHCHECK.TIMEOUTINMILLIS 300000
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_ENABLE_LOCAL_PLATFORM false
cf set-env skipper-luke SPRING_APPLICATION_JSON '{"maven": { "remote-repositories": { "repo1": { "url": "https://repo.spring.io/libs-snapshot"} } },"logging.level.com.zaxxer.hikari":"debug"}'
cf set-env skipper-luke FLYWAY_BASELINE_VERSION 0
cf set-env skipper-luke FLYWAY_BASELINE_ON_MIGRATE true
cf set-env skipper-luke SPRING_CLOUD_SKIPPER_SERVER_CLOUD_FOUNDRY_MAX_POOL_SIZE 2
cf bind-service skipper-luke postgres_skipper
cf start skipper-luke
