  echo 'Enter the PWS Username:'
  read USERNAME
  echo "Read In: $USERNAME"
  echo ""

  echo 'Enter the PWS Password:'
  read -s PASSWORD
  echo "Got a Password but will not echo it for security"
  echo ""

  echo 'Enter the PWS Organization:'
  read ORG
  echo "Read In: $ORG"
  echo ""

  echo 'Enter the PWS Space:'
  read SPACE
  echo "Read In: $SPACE"
  echo ""

  echo 'Enter the API (default is:https://api.run.pivotal.io)'
  read API
  echo "Read In: $API"
  echo ""

  if [ -z "$API" ]; then
    echo "Using default API"
    echo ""
    API='https://api.run.pivotal.io'
  fi

  echo "Credentials we will be using. Username: $USERNAME Password: ******** Organization: $ORG Space: $SPACE"
  echo ""

  #PCF has limit on the length of characters a route can be - as routes are based on app names we, need to shorten this
  source bin/trim-names.sh

  BASE_NAME=$(trimname $ORG $SPACE)

  # Create the names for the services and application
  ADMIN="$BASE_NAME-dataflow-server"
  REDIS="$BASE_NAME-scdf-redis"
  RABBIT="scdf-rabbitmq-queue"
  MYSQL="$BASE_NAME-scdf-mysql"

  echo "Are these credentials correct? (Type 'Y' to proceed)"
  read CONFIRMATION
  if [ "$CONFIRMATION" != "Y" ]; then
    echo "Terminating the program"
    exit 0;
  fi

  echo "Trying to login"
  cf login -a $API -u $USERNAME -p $PASSWORD -o $ORG -s $SPACE
  echo ""
