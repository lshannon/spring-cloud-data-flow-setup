echo "*****************************"
echo "* SCDF PWS SET UP		  *"
echo "*****************************"

# Read In Sensitive Data

echo "For the Admin Server to be able to create micro services for the stream we need the following:"

echo -n 'Enter the PWS Username:'
read -s USERNAME
echo

echo -n 'Enter the PWS Password:'
read -s PASSWORD
echo

echo -n 'Enter the PWS Organization:'
read -s ORG
echo

echo -n 'Enter the PWS Space:'
read -s SPACE
echo

echo -n "Credentials we will be using. Username: $USERNAME Password: $PASSWORD Organization: $ORG Space: $SPACE" 

echo "** Make sure you are logged into to PWS in a Space that will accomidate this deployment"
echo

echo "Creating the required Redis Service"
cf create-service rediscloud 30mb redis
echo

echo "Creating the required Rabbit Service"
cf create-service cloudamqp lemur rabbit
echo

echo "Creating the required MySql Service"
cf create-service cleardb spark mysql
echo

if [ ! -f spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.2.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
fi

if [ ! -f spring-cloud-dataflow-shell-1.2.3.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.2.3.RELEASE/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar
fi
echo

echo "Pusing the Server to PCF"
cf push $APP_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
echo

echo "Binding the Redis Service to the Server"
cf bind-service $APP_NAME redis
echo

echo "Binding the Rabbit Service to the Server"
cf bind-service $APP_NAME rabbit
echo

echo "Binding the MySql  Service to the Server"
cf bind-service $APP_NAME mysql
echo

echo "Setting the environmental variables"
cf set-env $APP_NAME MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES rabbit
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES redis,rabbit
echo "Setting Env for Username and Password silently"
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE

echo "Starting Up App"
cf start $APP_NAME
echo

echo "Set Up Complete"
