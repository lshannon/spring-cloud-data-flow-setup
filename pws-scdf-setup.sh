echo "*****************************"
echo "* SCDF PWS SET UP		  *"
echo "*****************************"

# Read In Sensitive Data

echo "To create the SCDF Server we will need PWS credentials."
echo "These will be used locally as well as passed to the server running in PWS"
echo ""

#Run script to collection credentails
. collect_credentials.sh

# Create the names for the services and application
ADMIN="$ORG$SPACE-dataflow-server"
REDIS="$ORG$SPACE-scdf-redis"
RABBIT="$ORG$SPACE-scdf-rabbit"
MYSQL="$ORG$SPACE-scdf-mysql"

echo "The Data Server will be called: $ADMIN "
echo "Redis Serivce: $REDIS"
echo "Rabbit Service: $RABBIT"
echo "MySQL: $MYSQL"
echo ""

echo "The following commands will be ran to set up your Server:"
echo "cf create-service rediscloud 30mb $REDIS"
echo "cf create-service cloudamqp lemur $RABBIT"
echo "cf create-service cleardb spark $MYSQL"
echo "(If you don't have it already) wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.2.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar"
echo "(If you don't have it already) wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.2.3.RELEASE/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar"
echo "cf push $ADMIN --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar"
echo "cf bind-service $ADMIN $REDIS"
echo "cf bind-service $ADMIN $RABBIT"
echo "cf bind-service $ADMIN $MYSQL"
echo "cf set-env $ADMIN MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $REDIS,$RABBIT"
echo "Setting Env for Username and Password silently"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD ********* > /dev/null"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE"
echo ""

echo "Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)"
read -s CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
	echo "Script Terminating"
	exit 0;
fi

echo "Creating the required Redis Service"
	cf create-service rediscloud 30mb $REDIS
echo ""

echo "Creating the required Rabbit Service"
	cf create-service cloudamqp lemur $RABBIT
echo ""

echo "Creating the required MySql Service"
	cf create-service cleardb spark $MYSQL
echo ""

echo "Checking for the Data Server Artifact to deploy to PWS: spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar"
echo ""

#make the directory if it does not exist
mkdir -p server

if [ ! -f server/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.2.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar -P server
fi
echo ""

#make the directory if it does not exist
mkdir -p shell

echo "Checking for the Data Flow shell for local use: spring-cloud-dataflow-shell-1.2.3.RELEASE.jar"
if [ ! -f shell/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.2.3.RELEASE/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar -P shell
fi
echo ""

echo "Pusing the Server to PCF"
	cf push $ADMIN --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
echo ""

echo "Binding the Redis Service to the Server"
	cf bind-service $ADMIN $REDIS
echo ""

echo "Binding the Rabbit Service to the Server"
	cf bind-service $ADMIN $RABBIT
echo ""

echo "Binding the MySql  Service to the Server"
	cf bind-service $ADMIN $MYSQL
echo ""

echo "Setting the environmental variables. The following will be ran:"

echo ""
cf set-env $ADMIN MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
cf set-env ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $REDIS,$RABBIT"
echo "Setting Env for Username and Password silently"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE
echo ""

echo "Starting Up App"
	cf start $ADMIN
echo

echo "Set Up Complete"
echo "You should now have a working SCDF Server at: https:$ADMIN.cfapps.io"
