#!/bin/bash
# Author: Luke Shannon
# Git Repo: https://github.com/lshannon/spring-cloud-data-flow-setup
# Disclaimer: This script sets up SCDF for training and eductional purposes only - NOT FOR PRODUCTION
#Set versions
SERVER_VERSION=2.0.0.RELEASE
SHELL_VERSION=2.0.0.RELEASE
SKIPPER_VERSION=2.0.0.RELEASE
echo "********************************************************************************"
echo "* "
echo "* Spring Cloud Dataflow (SCDF) Server Set Up For PWS Version: $SERVER_VERSION"
echo "* Author: Luke Shannon "
echo "* Git Repo: https://github.com/lshannon/spring-cloud-data-flow-setup "
echo "* Disclaimer: This script sets up SCDF for training and eductional purposes only"
echo "* !!! NOT FOR PRODUCTION !!!"
echo "* "
echo "********************************************************************************"
printf "\n\n"
# Check if the CF CLI is installed - without it the script needs to terminate
if ! [ -x "$(command -v cf)" ]; then
	echo " Need the CF cli"
	echo " Follow these directions: https://docs.run.pivotal.io/cf-cli/install-go-cli.html"
	echo " Re-run the script after the CLI is installed"
	exit 0;
fi

# Check for the required artifacts
source bin/download-artifacts.sh

echo "	The script will prompt for your PWS Username, Password, Organization and Space"
echo "	These are required to push the applications to PWS and create the required services"

#Run script to collection credentails
source bin/collect-credentials.sh $1
echo ""
echo "-------------------------------------------"
echo "- Data Flow Server will be called: $SERVER "
echo "- Skipper will be called: $SKIPPER "
echo "- The following services will be created: "
echo "- Rabbit Service: $RABBIT"
echo "- Postgres: $POSTGRES_SERVER"
echo "- Postgres: $POSTGRES_SKIPPER"
echo "- Scheduler: $SCHEDULER"
echo "-------------------------------------------"
echo ""

# Build the commands to run
# They need to be echo'd for confirmation and then executed

declare -a CreateServiceCommands=("cf create-service scheduler-for-pcf standard $SCHEDULER"
 "cf create-service cloudamqp lemur $RABBIT"
 "cf create-service elephantsql turtle $POSTGRES_SERVER"
 "cf create-service elephantsql turtle $POSTGRES_SKIPPER"
)

declare -a PushApps=("cf push $SERVER --no-start -b java_buildpack -m 1G -k 1G --no-start -p server/$SCDF_SERVER_NAME"
  "cf push $SKIPPER --no-start -b java_buildpack -m 1G -k 2G --no-start -p skipper/$SCDF_SKIPPER_NAME"
  "cf bind-service $SERVER $POSTGRES_SERVER"
	"cf bind-service $SERVER $SCHEDULER"
	"cf bind-service $SKIPPER $POSTGRES_SKIPPER"
)

declare -a ConfigureApps=("cf set-env $SERVER MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
"cf set-env $SERVER SPRING_CLOUD_SCHEDULER_CLOUDFOUNDRY_SCHEDULER_URL https://scheduler.run.pivotal.io"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $POSTGRES_SERVER, $SCHEDULER"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG"
"cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE"
"cf set-env $SERVER SPRING_CLOUD_SKIPPER_CLIENT_SERVER_URI https://$SKIPPER.cfapps.io/api"
"cf set-env $SERVER SPRING_APPLICATION_JSON '{ \"spring.cloud.dataflow.server.cloudfoundry.maxPoolSize\":\"2\",\"logging.level.com.zaxxer.hikari\":\"debug\"}'"
"cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_SKIPPER_ENABLED true"
"cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_ANALYTICS_ENABLED false"
"cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_SCHEDULES_ENABLED true"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX true"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_DOMAIN cfapps.io"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SKIP_SSL_VALIDATION false"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_PASSWORD $PASSWORD > /dev/null"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_USERNAME $USERNAME > /dev/null"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SPACE $SPACE"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_ORG $ORG"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_URL https://api.run.pivotal.io"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_STRATEGIES_HEALTHCHECK.TIMEOUTINMILLIS 300000"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_SERVICES $RABBIT"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX true"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_ENABLE_LOCAL_PLATFORM false"
"cf set-env $SKIPPER SPRING_APPLICATION_JSON '{\"maven\": { \"remote-repositories\": { \"repo1\": { \"url\": \"https://repo.spring.io/libs-snapshot\"} } }, \"spring.cloud.skipper.server.cloudfoundry.maxPoolSize\":\"2\",\"logging.level.com.zaxxer.hikari\":\"debug\"}'"
"cf set-env $SKIPPER FLYWAY_BASELINE_VERSION 0"
"cf set-env $SKIPPER FLYWAY_BASELINE_ON_MIGRATE true"
"cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_CLOUD_FOUNDRY_MAX_POOL_SIZE 2"
)

# Echo the commands for verification
echo "	The following commands will be ran to set up your SCDF install"
echo "	To Create the required Services from the PWS Marketplace:"
echo ""
echo "	Create the services from PWS marketplace:"
for (( i = 0; i < ${#CreateServiceCommands[@]} ; i++ )); do
    echo "		${CreateServiceCommands[$i]}"
done
printf "\n\n"

echo "	Push Apps to PWS:"
for (( i = 0; i < ${#PushApps[@]} ; i++ )); do
    echo "		${PushApps[$i]}"
done
printf "\n\n"

echo "	Configure The Applications In PWS:"
for (( i = 0; i < ${#ConfigureApps[@]} ; i++ )); do
    echo "		${ConfigureApps[$i]}"
done
printf "\n\n"

echo "	Do you wish to run these commands? (Type 'Y' to proceed)"
read CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
	echo "	That's a copy...script terminating"
	exit 0;
fi
echo ""
echo "	OK, let's do this!"
echo ""
#Run the commands
echo "	Creating the services:"
for (( i = 0; i < ${#CreateServiceCommands[@]} ; i++ )); do
    eval "${CreateServiceCommands[$i]}"
done
printf "\n\n"

echo "	Pushing the applications:"
for (( i = 0; i < ${#PushApps[@]} ; i++ )); do
    eval "${PushApps[$i]}"
done
printf "\n\n"

echo "	Configuring the applications:"
for (( i = 0; i < ${#ConfigureApps[@]} ; i++ )); do
    eval "${ConfigureApps[$i]}"
done
printf "\n\n"

# Start the applications
echo "	Starting Up SCDF Server"
	cf start $SERVER
printf "\n\n"

echo "	Starting Up Skipper"
	cf start $SKIPPER
printf "\n\n"

echo "****************************************************************"
echo "*											Set Up Complete   												*"
echo "****************************************************************"
echo "	Provided there were no errors, your SCDF Server should be at:"
echo "		https//:$SERVER.cfapps.io"
