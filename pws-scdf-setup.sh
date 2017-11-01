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

echo -n "Credentials we will be using. Username: $USERNAME Password: ******** Organization: $ORG Space: $SPACE" 

echo "** Make sure you are logged into to PWS in a Space that will accomidate this deployment"
echo

# Create the names for the services and application
ADMIN=$ORG$SPACE-dataflow-server
REDIS=$ORG$SPACEredis
RABBIT=$ORG$SPACEredis
MYSQL=$ORG$SPACEredis

echo "The Admin Server will be called: $ADMIN Redis Serivce: $REDIS Rabbit Service: $RABBIT MySQL: $MYSQL"

echo "Creating the required Redis Service"
echo "cf create-service rediscloud 30mb $ORG$SPACEredis"
#`cf create-service rediscloud 30mb $ORG$SPACEredis`
echo

echo "Creating the required Rabbit Service"
echo "cf create-service cloudamqp lemur $ORG$SPACEredis"
#cf create-service cloudamqp lemur $ORG$SPACEredis
echo

echo "Creating the required MySql Service"
echo "cf create-service cleardb spark $ORG$SPACEredis"
#cf create-service cleardb spark $ORG$SPACEredis
echo

echo "Checking for the Data Server Artifact to deploy to PWS: spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar"

if [ ! -f spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	#wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.2.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
fi

echo "Checking for the Data Flow shell for local use: spring-cloud-dataflow-shell-1.2.3.RELEASE.jar"

if [ ! -f spring-cloud-dataflow-shell-1.2.3.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	#wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.2.3.RELEASE/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar
fi
echo

echo "Pusing the Server to PCF"
echo "cf push $ADMIN_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar"
#cf push $ADMIN_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
echo

echo "Binding the Redis Service to the Server"
echo "cf bind-service $ADMIN_NAME $REDIS"
#cf bind-service $ADMIN_NAME $REDIS
echo

echo "Binding the Rabbit Service to the Server"
echo "cf bind-service $APP_NAME $RABBIT"
#cf bind-service $APP_NAME $RABBIT
echo

echo "Binding the MySql  Service to the Server"
echo "cf bind-service $APP_NAME $MYSQL"
#cf bind-service $APP_NAME $MYSQL
echo

echo "Setting the environmental variables"
echo "cf set-env $APP_NAME MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $REDIS,$RABBIT"
echo "Setting Env for Username and Password silently"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG"
echo "cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE"

echo "Starting Up App"
cf start $APP_NAME
echo

echo "Set Up Complete"
