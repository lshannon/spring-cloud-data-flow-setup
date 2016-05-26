echo " $$$$$$\   $$$$$$\  $$$$$$$\  $$$$$$$$\       $$$$$$$\                                    ";
echo "$$  __$$\ $$  __$$\ $$  __$$\ $$  _____|      $$  __$$\                                   ";
echo "$$ /  \__|$$ /  \__|$$ |  $$ |$$ |            $$ |  $$ | $$$$$$\  $$$$$$\$$$$\   $$$$$$\  ";
echo "\$$$$$$\  $$ |      $$ |  $$ |$$$$$\          $$ |  $$ |$$  __$$\ $$  _$$  _$$\ $$  __$$\ ";
echo " \____$$\ $$ |      $$ |  $$ |$$  __|         $$ |  $$ |$$$$$$$$ |$$ / $$ / $$ |$$ /  $$ |";
echo "$$\   $$ |$$ |  $$\ $$ |  $$ |$$ |            $$ |  $$ |$$   ____|$$ | $$ | $$ |$$ |  $$ |";
echo "\$$$$$$  |\$$$$$$  |$$$$$$$  |$$ |            $$$$$$$  |\$$$$$$$\ $$ | $$ | $$ |\$$$$$$  |";
echo " \______/  \______/ \_______/ \__|            \_______/  \_______|\__| \__| \__| \______/ ";
echo "                                                                                          ";
echo "                                                                                          ";
echo "                                                                                          ";
if [ $# -eq 0 ]; then
	echo "Usage: demo_setup_1.sh <organization> <space> <email> <password>";
	echo "Program terminating ...";
	exit 1;
fi

APP_NAME=$2-dataflow-server

#echo "Setting the end point for PWS"
#cf api https://api.run.pivotal.io

echo "Running: cf login"
cf login -a https://api.run.pivotal.io -u "$3" -p "$4" -o "$1" -s "$2" 

echo "Creating the required Redis Service"
cf create-service rediscloud 30mb redis

echo "Creating the required Rabbit Service"
cf create-service cloudamqp lemur rabbit

if [ ! -f spring-cloud-dataflow-server-cloudfoundry-1.0.0.BUILD-SNAPSHOT.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/snapshot/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.0.0.BUILD-SNAPSHOT/spring-cloud-dataflow-server-cloudfoundry-1.0.0.BUILD-SNAPSHOT.jar
fi

if [ ! -f spring-cloud-dataflow-shell-1.0.0.BUILD-SNAPSHOT.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/snapshot/org/springframework/cloud/spring-cloud-dataflow-shell/1.0.0.BUILD-SNAPSHOT/spring-cloud-dataflow-shell-1.0.0.BUILD-SNAPSHOT.jar
fi

echo "Pusing the Server to PCF"
cf push $APP_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.0.0.BUILD-SNAPSHOT.jar

echo "Binding the Redis Service to the Server"
cf bind-service $APP_NAME redis

echo "Binding the Rabbit Service to the Server"
cf bind-service $APP_NAME rabbit

echo "Setting the environmental variables"
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_API_ENDPOINT https://api.run.pivotal.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORGANIZATION "$1"
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $2
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES redis,rabbit
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $3
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $4
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false

echo "Starting the Server"
cf start $APP_NAME

echo "Set Up Complete"

