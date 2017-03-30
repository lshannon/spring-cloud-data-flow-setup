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

APP_NAME=luke-dataflow-server

echo "** Make sure you are logged into to PWS in a Space that will accomidate this deployment"

echo "Creating the required Redis Service"
cf create-service rediscloud 30mb redis

echo "Creating the required Rabbit Service"
cf create-service cloudamqp lemur rabbit

echo "Creating the required MySql Service"
cf create-service cleardb spark mysql

if [ ! -f spring-cloud-dataflow-server-cloudfoundry-1.1.1.RELEASE.jar ]; then
	echo "Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.1.1.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.1.1.RELEASE.jar
fi

if [ ! -f spring-cloud-dataflow-shell-1.1.1.RELEASE.jar ]; then
	echo "Downloading the Shell Application to run locally to connect to the server in PCF"
	wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.1.1.RELEASE/spring-cloud-dataflow-shell-1.1.1.RELEASE.jar
fi

echo "Pusing the Server to PCF"
cf push $APP_NAME --no-start -p spring-cloud-dataflow-server-cloudfoundry-1.1.1.RELEASE.jar

echo "Binding the Redis Service to the Server"
cf bind-service $APP_NAME redis

echo "Binding the Rabbit Service to the Server"
cf bind-service $APP_NAME rabbit

echo "Binding the MySql  Service to the Server"
cf bind-service $APP_NAME mysql

echo "Setting the environmental variables"
cf set-env $APP_NAME MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES rabbit
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false
cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES redis,rabbit

echo "Run: cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME *********
echo "Run: cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD *********"
echo "Run: cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG '*********' "
echo "Run: cf set-env $APP_NAME SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE *******"

echo "Run cf start $APP_NAME"

echo "Set Up Complete"
