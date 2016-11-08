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
	echo "Usage: pcfdev-scdf-setup.sh pcfdev-org pcfdev-space admin admin";
	echo "Program terminating ...";
	exit 1;
fi

APP_NAME=$3-dataflow-server

#echo "Setting the end point for PWS"
#cf api https://api.run.pivotal.io

echo "Running: cf login"
cf login -a https://api.local.pcfdev.io --skip-ssl-validation -u "$3" -p "$4" -o "$1" -s "$2"  

p-mysql      512mb, 1gb   MySQL databases on demand
p-rabbitmq   standard     RabbitMQ is a robust and scalable high-performance multi-protocol messaging broker.
p-redis      shared-vm    Redis service to provide a key-value store

echo "Creating the required Redis Service"
cf create-service p-redis shared-vm redis

echo "Creating the required Rabbit Service"
cf create-service p-rabbitmq standard  rabbit

echo "Creating the required MySql Service"
cf create-service p-mysql 512mb  mysql

if [ ! -f spring-cloud-dataflow-server-cloudfoundry-1.0.1.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.0.1.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.0.1.RELEASE.jar
fi

if [ ! -f spring-cloud-dataflow-shell-1.0.1.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.0.1.RELEASE/spring-cloud-dataflow-shell-1.0.1.RELEASE.jar
fi

echo "Pusing the Server to PCF"
cf push $APP_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.0.1.RELEASE.jar

echo "Binding the Redis Service to the Server"
cf bind-service $APP_NAME redis

echo "Binding the Rabbit Service to the Server"
cf bind-service $APP_NAME rabbit

echo "Binding the MySql  Service to the Server"
cf bind-service $APP_NAME mysql

echo "Setting the environmental variables"
cf set-env $APP_NAME MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.local.pcfdev.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG "$1"
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE $2
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN pcfdev.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES rabbit
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME $3
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD $4
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES redis,rabbit, mysql


echo "Starting the Server"
cf start $APP_NAME

echo "Set Up Complete"

