echo "Do you want this script to log you into the Org/Space you wish to set this up in? (type 'Y' to login, type 'N' to continue with current login):"
read -s CONFIRMATION
if [ "$CONFIRMATION" == "Y" ]; then
  echo 'Enter the PWS Username:'
  read -s USERNAME
  echo "Read In: $USERNAME"
  echo ""

  echo 'Enter the PWS Password:'
  read -s PASSWORD
  echo "Got a Password but will not echo it for security"
  echo ""

  echo 'Enter the PWS Organization:'
  read -s ORG
  echo "Read In: $ORG"
  echo ""

  echo 'Enter the PWS Space:'
  read -s SPACE
  echo "Read In: $SPACE"
  echo ""

  echo "Credentials we will be using. Username: $USERNAME Password: ******** Organization: $ORG Space: $SPACE"
  echo ""

  echo "Are these credentials correct? (Type 'Y' to proceed)"
  read -s CONFIRMATION
  if [ "$CONFIRMATION" != "Y" ]; then
    echo "Terminating the program"
    exit 0;
  fi

  echo "Trying to login"
  cf login -a https://api.run.pivotal.io -u $USERNAME -p $PASSWORD -o $ORG -s $SPACE
  echo ""

fi
