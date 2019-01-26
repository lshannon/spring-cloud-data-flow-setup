#Set versions
SERVER_VERSION=1.7.3.RELEASE
SHELL_VERSION=1.7.3.RELEASE
SKIPPER_VERSION=1.1.3.BUILD-SNAPSHOT
echo "*********************************************************************************"
echo "*   Spring Cloud Dataflow (SCDF) Server Set Up For PWS Version: $SERVER_VERSION *"
echo "*********************************************************************************"

# Read In Sensitive Data

echo "This script will set up a SCDF Server and Skipper Server"
echo "Server Version: $SERVER_VERSION"
echo "Shell Version: $SHELL_VERSION"
echo "Skipper Version: $SKIPPER_VERSION"
echo "The script will prompt for your Username, Password, Organization and Space"
echo "This script will create services"

#Run script to collection credentails
source bin/collect-credentials.sh

echo "Data Flow Server will be called: $SERVER "
echo "Skipper will be called: $SKIPPER "
echo "The following services will be created: "
echo "Rabbit Service: $RABBIT"
echo "Postgres: $POSTGRES_SERVER"
echo "Postgres: $POSTGRES_SKIPPER"
echo "Scheduler: $SCHEDULER"
echo ""

#Binaries and application names to USERNAME
SCDF_SERVER_URL="http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/$SERVER_VERSION.RELEASE/spring-cloud-dataflow-server-cloudfoundry-$SERVER_VERSION.RELEASE.jar"
SCDF_SERVER_NAME="spring-cloud-dataflow-server-cloudfoundry-$SERVER_VERSION.jar"
SCDF_SHELL_URL="http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/$SHELL_VERSION.RELEASE/spring-cloud-dataflow-shell-$SHELL_VERSION.RELEASE.jar"
SCDF_SHELL_NAME="spring-cloud-dataflow-shell-$SHELL_VERSION.jar"
SCDF_SKIPPER_URL="http://repo.spring.io/release/org/springframework/cloud/spring-cloud-skipper-server/$SKIPPER_VERSION.RELEASE/spring-cloud-skipper-server-$SKIPPER_VERSION.RELEASE.jar"
SCDF_SKIPPER_NAME="spring-cloud-skipper-server-$SKIPPER_VERSION.jar"

echo "The following commands will be ran to set up your Server:"
#create services
echo "cf create-service cloudamqp lemur $RABBIT"
echo "cf create-service elephantsql turtle $POSTGRES_SERVER"
echo "cf create-service elephantsql turtle $POSTGRES_SKIPPER"
echo "(If you don't have it already) wget $SCDF_SERVER_URL"
echo "(If you don't have it already) wget $SCDF_SHELL_URL"
echo "(If you don't have it already) wget $SCDF_SKIPPER_URL"
#push apps
echo "cf push $SERVER --no-start -b java_buildpack -m 2G -k 2G --no-start -p server/$SCDF_SERVER_NAME"
echo "cf push $SERVER --no-start -b java_buildpack -m 2G -k 2G --no-start -p server/$SKIPPER_SERVER_NAME"
#configure apps
echo "cf bind-service $SERVER $POSTGRES"
echo "cf set-env $ MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
#echo "cf set-env $SKIPPER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $POSTGRES"
echo "Setting Env for Username and Password silently"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD ********* > /dev/null"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE"
echo "cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_API_TIMEOUT 500"
#Uncomment for debugging issues
#echo "cf set-env $SERVER JAVA_OPTS '-Dlogging.level.cloudfoundry-client=DEBUG -Dlogging.level.reactor.ipc.netty=DEBUG'"
echo "$SERVER"
echo ""

echo "Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)"
read CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
	echo "Script Terminating"
	exit 0;
fi

echo "Create the scheduler service"
	cf create-service scheduler-for-pcf standard $SCHEDULER
echo ""

echo "Creating the required Rabbit Service"
	cf create-service cloudamqp lemur $RABBIT
echo ""

echo "Creating the required Postgres Service"
	cf create-service elephantsql turtle $POSTGRES_SERVER
echo ""

echo "Creating the required Postgres Service"
	cf create-service elephantsql turtle $POSTGRES_SKIPPER
echo ""

echo "Checking for the Data Server Artifact to deploy to PWS: $SCDF_SERVER_NAME"
echo ""

#make the directory if it does not exist
mkdir -p server

if [ ! -f server/$SCDF_SERVER_NAME ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget $SCDF_SERVER_URL -P server
fi
echo ""

echo "Checking for the Data Server Artifact to deploy to PWS: $SCDF_SKIPPER_NAME"
echo ""

#skipper set up
mkdir -p skipper
if [ ! -f skipper/$SCDF_SKIPPER_NAME ]; then
	echo "Downloading the Skipper App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget $SCDF_SKIPPER_URL -P skipper
fi
echo ""

#make the directory if it does not exist
mkdir -p shell

echo "Checking for the Data Flow shell for local use: spring-cloud-dataflow-shell-1.3.1.RELEASE.jar"
if [ ! -f shell/$SCDF_SHELL_NAME ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget $SCDF_SHELL_URL -P shell
fi
echo ""

echo "Pusing the Server to PCF"
	cf push $SERVER --no-start -b java_buildpack -m 1G -k 1G --no-start -p server/$SCDF_SERVER_NAME
echo ""

echo "Pusing the Skipper to PCF"
	cf push $SKIPPER --no-start -b java_buildpack -m 1G -k 2G --no-start -p skipper/$SCDF_SKIPPER_NAME
echo ""

echo "Binding the Postgres  Service to the Server"
	cf bind-service $SERVER $POSTGRES_SERVER
echo ""

echo "Binding the Scheduler Service to the Server"
	cf bind-service $SERVER $SCHEDULER
echo ""

echo "Binding the Postgres Service to Skipper"
	cf bind-service $SKIPPER $POSTGRES_SKIPPER
echo ""

echo "Setting the environmental variables. The following will be ran:"

echo ""
cf set-env $SERVER MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env $SERVER SPRING_CLOUD_SCHEDULER_CLOUDFOUNDRY_SCHEDULER_URL https://scheduler.run.pivotal.io
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $POSTGRES_SERVER, $SCHEDULER
echo "Setting Env for Username and Password silently"
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG
cf set-env $SERVER SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE
cf set-env $SERVER SPRING_CLOUD_SKIPPER_CLIENT_SERVER_URI https://$SKIPPER.cfapps.io/api
cf set-env $SERVER SPRING_APPLICATION_JSON '{ "spring.cloud.dataflow.server.cloudfoundry.maxPoolSize":"2","logging.level.com.zaxxer.hikari":"debug"}'
cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_SKIPPER_ENABLED true
cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_ANALYTICS_ENABLED false
cf set-env $SERVER SPRING_CLOUD_DATAFLOW_FEATURES_SCHEDULES_ENABLED true
# configure SKIPPER
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX true
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_DOMAIN cfapps.io
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SKIP_SSL_VALIDATION false
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_PASSWORD $PASSWORD > /dev/null
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_USERNAME $USERNAME > /dev/null
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_SPACE $SPACE
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_ORG $ORG
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_CONNECTION_URL https://api.run.pivotal.io
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_STRATEGIES_HEALTHCHECK.TIMEOUTINMILLIS 300000
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_SERVICES $RABBIT
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[default]_DEPLOYMENT_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX true
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_ENABLE_LOCAL_PLATFORM false
cf set-env $SKIPPER SPRING_APPLICATION_JSON '{"maven": { "remote-repositories": { "repo1": { "url": "https://repo.spring.io/libs-snapshot"} } }, "spring.cloud.skipper.server.cloudfoundry.maxPoolSize":"2","logging.level.com.zaxxer.hikari":"debug"}'
cf set-env $SKIPPER FLYWAY_BASELINE_VERSION 0
cf set-env $SKIPPER FLYWAY_BASELINE_ON_MIGRATE true
cf set-env $SKIPPER SPRING_CLOUD_SKIPPER_SERVER_CLOUD_FOUNDRY_MAX_POOL_SIZE 2
#uncomment for debugging
#cf set-env $SERVER JAVA_OPTS '-Dlogging.level.cloudfoundry-client=DEBUG -Dlogging.level.reactor.ipc.netty=DEBUG'
echo ""

echo "Starting Up App"
	cf start $SERVER
echo

echo "Starting Up App"
	cf start $SKIPPER
echo

echo "Set Up Complete"
echo "You should now have a working SCDF Server at: https//:$SERVER.cfapps.io"
