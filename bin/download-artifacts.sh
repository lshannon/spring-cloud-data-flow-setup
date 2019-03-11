#!/bin/bash
# Author: Luke Shannon
# Git Repo: https://github.com/lshannon/spring-cloud-data-flow-setup
# Disclaimer: This script sets up SCDF for training and eductional purposes only - NOT FOR PRODUCTION

# Build the URLs for the binaries
SCDF_SERVER_URL="https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-server/$SERVER_VERSION/spring-cloud-dataflow-server-$SERVER_VERSION.jar"
SCDF_SERVER_NAME="spring-cloud-dataflow-server-$SERVER_VERSION.jar"
SCDF_SHELL_URL="http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/$SHELL_VERSION/spring-cloud-dataflow-shell-$SHELL_VERSION.jar"
SCDF_SHELL_NAME="spring-cloud-dataflow-shell-$SHELL_VERSION.jar"
SCDF_SKIPPER_URL="http://repo.spring.io/release/org/springframework/cloud/spring-cloud-skipper-server/$SKIPPER_VERSION/spring-cloud-skipper-server-$SKIPPER_VERSION.jar"
SCDF_SKIPPER_NAME="spring-cloud-skipper-server-$SKIPPER_VERSION.jar"

echo "	This script will set up a SCDF Server and Skipper Server"
echo "		Server Version: $SERVER_VERSION"
echo "		Shell Version: $SHELL_VERSION"
echo "		Skipper Version: $SKIPPER_VERSION"
printf "\n\n"

echo "	Checking for the Data Server Artifact to deploy to PWS: $SCDF_SERVER_NAME"
echo ""

#make the directory if it does not exist
mkdir -p server

# check if there is a server binary
if [ ! -f server/$SCDF_SERVER_NAME ]; then
	echo "	Downloading the Server App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	#ensure the URL actually has the binary
	wget_output=`wget -q $SCDF_SERVER_URL`
	if [ $? -ne 0 ]; then
	 	echo "	$SCDF_SERVER_URL does not contain a binary. Script terminating"
		exit 0;
	fi
	wget $SCDF_SERVER_URL -P server
fi
echo ""

echo "	Checking for the Data Server Artifact to deploy to PWS: $SCDF_SKIPPER_NAME"
echo ""

#make the skipper directory if it did not exist
mkdir -p skipper

#check for the artifact and download if its not present
if [ ! -f skipper/$SCDF_SKIPPER_NAME ]; then
	echo "	Downloading the Skipper App for Pivotal Cloud Foundry. This will be deployed in Cloud Foundry"
	#ensure the URL actually has the binary
	wget_output=`wget -q $SCDF_SKIPPER_URL`
	if [ $? -ne 0 ]; then
		echo "	$SCDF_SKIPPER_URL does not contain a binary. Script terminating"
		exit 0;
	fi
	wget $SCDF_SKIPPER_URL -P skipper
fi
echo ""

#make the shell directory if it does not exist
mkdir -p shell

echo "	Checking for the Data Flow shell for local use: $SCDF_SHELL_NAME"
#check for the artifact and download if its not present
if [ ! -f shell/$SCDF_SHELL_NAME ]; then
	echo "	Downloading the Shell Application to run locally to connect to the server in PCF"
	#ensure the URL actually has the binary
	wget_output=`wget -q $SCDF_SHELL_URL`
	if [ $? -ne 0 ]; then
		echo "	$SCDF_SHELL_URL does not contain a binary. Script terminating"
		exit 0;
	fi
	wget $SCDF_SHELL_URL -P shell
fi

echo ""
