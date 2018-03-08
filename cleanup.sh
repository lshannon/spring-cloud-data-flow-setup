echo "*****************************"
echo "* SCDF PWS CLEAN UP		      *"
echo "*****************************"
echo ""
echo "To delete the SCDF Server and all its services we will need credentials to your PWS account and the Org and Space"

#Run script to collection credentails
source bin/collect-credentials.sh

#Review the commands to Run
echo "The following commands will be ran to set up your Server:"
echo "cf delete $ADMIN -f"
echo "cf delete-service $REDIS -f"
echo "cf delete-service $MYSQL -f"
echo "cf delete-orphaned-routes -f"
echo ""

echo "Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)"
read CONFIRMATION
if [ "$CONFIRMATION" != "Y" ]; then
  echo "Script Terminating"
	exit 0;
fi

echo "Deleting the Server in PWS"
	cf delete $ADMIN -f
echo ""

echo "Deleting the Redis Service"
	cf delete-service $REDIS -f
echo ""

echo "Deleting the MySql Service"
	cf delete-service $MYSQL -f
echo ""

echo "Removing Orphaned Routes"
  cf delete-orphaned-routes -f
echo ""

echo "Clean Up Completed"
echo ""

echo "Applications running in the space (some workers may still need to be deleted):"
echo ""
OUTPUT="$(cf apps)"
echo "$OUTPUT"
echo ""
echo "To delete applications:"
echo "cf delete <app name> -f"
