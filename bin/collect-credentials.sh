#!/bin/bash
# Author: Luke Shannon
# Git Repo: https://github.com/lshannon/spring-cloud-data-flow-setup
# Disclaimer: This script sets up SCDF for training and eductional purposes only - NOT FOR PRODUCTION
  echo 'Enter the PWS Username:'
  if [ "$1" == 'echo' ] ; then
      read USERNAME
      echo "Read In: $USERNAME"
  else
    read -s USERNAME
    echo "Got a Username but will not echo it for security"
  fi
  echo ""

  echo 'Enter the PWS Password:'
  if [ "$1" == 'echo' ] ; then
    read PASSWORD
    echo "Read In: $PASSWORD"
  else
    read -s PASSWORD
    echo "Got a Password but will not echo it for security"
  fi
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

  if [ "$1" == 'echo' ] ; then
    echo "Credentials we will be using. Username: $USERNAME Password: $PASSWORD Organization: $ORG Space: $SPACE"
  else
      echo "Credentials we will be using. Username: ******** Password: ******** Organization: $ORG Space: $SPACE"
  fi

  echo ""

  #PCF has limit on the length of characters a route can be - as routes are based on app names we, need to shorten this
  source bin/trim-names.sh

  BASE_NAME=$(trimname $ORG $SPACE)

  # Create the names for the services and application
  SERVER="$BASE_NAME-server"
  SKIPPER="$BASE_NAME-skipper"
  RABBIT="$BASE_NAME-rabbitmq-queue"
  POSTGRES_SERVER="$BASE_NAME-postgres-server"
  POSTGRES_SKIPPER="$BASE_NAME-postgres-skipper"
  SCHEDULER="$BASE_NAME-scheduler"

  echo "Are these credentials correct? (Type 'Y' to proceed)"
  read CONFIRMATION
  if [ "$CONFIRMATION" != "Y" ]; then
    echo "Terminating the program"
    exit 0;
  fi

  echo "Trying to login"
  cf login -a $API -u $USERNAME -p $PASSWORD -o $ORG -s $SPACE
  echo ""
