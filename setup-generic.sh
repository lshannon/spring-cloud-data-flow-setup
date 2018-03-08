echo "*******************************************"
echo "*  Spring Cloud Data Flow Admin Set Up		 *"
echo "*******************************************"

# Read In Sensitive Data

echo "This script will set up SCDF for running the message-stream-processing sample"
echo "The script will prompt for your Username, Password, Organization and Space"
echo "This samples requires a more robust RabbitMQ plan (ie: Tiger)"

#Run script to collection credentails
source bin/collect-credentials.sh

echo "The Data Server will be called: $ADMIN "

echo 'Enter the Redis Service Name:'
read REDIS
echo "Read In: $REDIS"
echo ""

if [ -z "$REDIS" ]; then
	echo "The name of a Redis Service must be supplied"
	echo "Program Terminating"
	exit 0;
fi

echo 'Enter the Rabbit Service Name:'
read RABBIT
echo "Read In: $RABBIT"
echo ""

if [ -z "$RABBIT" ]; then
	echo "The name of a Rabbit Service must be supplied"
	echo "Program Terminating"
	exit 0;
fi

echo 'Enter the MySQL Service Name:'
read MYSQL
echo "Read In: $MYSQL"
echo ""

if [ -z "$MYSQL" ]; then
	echo "The name of a Rabbit Service must be supplied"
	echo "Program Terminating"
	exit 0;
fi

echo "The following services will be bound to the SCDF admin application: "
echo "Redis Serivce: $REDIS"
echo "Rabbit Service: $RABBIT"
echo "MySQL: $MYSQL"
echo ""

echo "The following commands will be ran to set up your Server:"
echo "(If you don't have it already) wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.3.0.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar"
echo "(If you don't have it already) http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.3.1.RELEASE/spring-cloud-dataflow-shell-1.3.1.RELEASE.jar"
echo "cf push $ADMIN --no-start -m 2G -k 2G --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar"
echo "cf bind-service $ADMIN $REDIS"
echo "cf bind-service $ADMIN $RABBIT"
echo "cf bind-service $ADMIN $MYSQL"
echo "cf set-env $ADMIN MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $REDIS,$MYSQL"
echo "Setting Env for Username and Password silently"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD ********* > /dev/null"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE"
echo "cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_API_TIMEOUT 500"
#Uncomment for debugging issues
#echo "cf set-env $ADMIN JAVA_OPTS '-Dlogging.level.cloudfoundry-client=DEBUG -Dlogging.level.reactor.ipc.netty=DEBUG'"
echo "$ADMIN"
echo ""

echo "Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)"
read CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
	echo "Script Terminating"
	exit 0;
fi

echo "Checking for the Data Server Artifact to deploy to PWS: spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar"
echo ""

#make the directory if it does not exist
mkdir -p server

if [ ! -f server/spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.3.0.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar -P server
fi
echo ""

#make the directory if it does not exist
mkdir -p shell

echo "Checking for the Data Flow shell for local use: spring-cloud-dataflow-shell-1.3.1.RELEASE.jar"
if [ ! -f shell/spring-cloud-dataflow-shell-1.3.1.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.3.1.RELEASE/spring-cloud-dataflow-shell-1.3.1.RELEASE.jar -P shell
fi
echo ""

echo "Pusing the Server to PCF"
	cf push $ADMIN --no-start -m 2G -k 2G --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.3.0.RELEASE.jar
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
cf set-env $ADMIN MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES $RABBIT
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES $REDIS,$MYSQL
echo "Setting Env for Username and Password silently"
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $USERNAME > /dev/null
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $PASSWORD > /dev/null
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG $ORG
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $SPACE
cf set-env $ADMIN SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_API_TIMEOUT 500
#uncomment for debugging
#cf set-env $ADMIN JAVA_OPTS '-Dlogging.level.cloudfoundry-client=DEBUG -Dlogging.level.reactor.ipc.netty=DEBUG'
echo ""

echo "Starting Up App"
	cf start $ADMIN
echo

echo "Set Up Complete"
echo "You should now have a working SCDF Server at: https:$ADMIN.cfapps.io"
