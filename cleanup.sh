echo "********************************************************************************"
echo "* "
echo "* Spring Cloud Dataflow (SCDF) Server Clean Up For PWS Version: $SERVER_VERSION"
echo "* Author: Luke Shannon "
echo "* Git Repo: https://github.com/lshannon/spring-cloud-data-flow-setup "
echo "* Disclaimer: This script cleans up a SCDF Install on PWS that was set up"
echo "* with the set-up.sh script included in the repo"
echo "* all services and data will be deleted without any attempt to"
echo "* back up any of the data"
echo "* "
echo "********************************************************************************"
printf "\n\n"
echo "To delete the SCDF Server and all its services we will need credentials to your PWS account and the Org and Space"

#Run script to collection credentails
source bin/collect-credentials.sh

#Review the commands to Run
echo "The following commands will be ran to set up your Server:"
echo "cf delete $SERVER -f"
echo "cf delete $SKIPPER -f"
echo "cf delete-service $POSTGRES_SERVER -f"
echo "cf delete-service $POSTGRES_SKIPPER -f"
echo "cf delete-service $RABBIT -f"
echo "cf delete-service $SCHEDULER -f"
echo "cf delete-orphaned-routes -f"
echo ""

echo "Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)"
read CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
  echo "Script Terminating"
	exit 0;
fi

echo "Deleting the Server in PWS"
	cf delete $SERVER -f
echo ""

echo "Deleting Skipper in PWS"
	cf delete $SKIPPER -f
echo ""

echo "Deleting the Rabbit Service"
	cf delete-service $RABBIT -f
echo ""

echo "Deleting the Postgres Service"
	cf delete-service $POSTGRES_SERVER -f
echo ""

echo "Deleting the Postgres Service"
	cf delete-service $POSTGRES_SKIPPER -f
echo ""

echo "Deleting the Schedule Service"
  cf delete-service $SCHEDULER -f
echo ""

echo "Removing Orphaned Routes"
  cf delete-orphaned-routes -f
echo ""

echo "Clean Up Completed"
echo ""

echo 'Applications running in the space (some workers may still need to be deleted):'
echo ""
OUTPUT="$(cf apps)"
echo "$OUTPUT"
echo ""
echo "To delete applications:"
echo "cf delete <app name> -f"
