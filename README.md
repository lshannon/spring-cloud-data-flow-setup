# Spring Cloud Data Flow Set Up

This is a simple demo to help you get up and running using Spring Cloud Data Flow (SCDF) on Pivotal Web Services (PWS). In this repo you will find:

1. Steps to get a SCDF Server running in PWS
2. Set Up the SCDF Shell locally
3. Get a 'Hello World' equivilant going for SCDF

## Setting Up The SCDF Server

The following steps need to be completed to get the server set up to submit Spring Cloud Data Flow streams.

1. Download the SCDF project
2. Download the Spring Cloud Shell project
3. Create a Redis Service in PCF
4. Create a Rabbit Service in PCF
5. Push the Server project into PCF (stopped)
6. Set up environmental variables for the Server to integrate with the elastic runtime of PCF
7. Start the Server

Running pws-scdf-setup.sh will perform all the steps on PWS (run.pivotal.io). The script will prompt for the organization, space, username and password as arguements.

It will create a server based on the name of our Org and Space. Then it will run on the necessary commands to set everything up. A preview of these commands will be listed and a chance to cancel if you get scared.

```shell

./pws-scdf-setup.sh

...

The Data Server will be called: cloud-nativedevelopment-dataflow-server 
Redis Serivce: cloud-nativedevelopment-scdf-redis
Rabbit Service: cloud-nativedevelopment-scdf-rabbit
MySQL: cloud-nativedevelopment-scdf-mysql

The following commands will be ran to set up your Server:
cf create-service rediscloud 30mb cloud-nativedevelopment-scdf-redis
cf create-service cloudamqp lemur cloud-nativedevelopment-scdf-rabbit
cf create-service cleardb spark cloud-nativedevelopment-scdf-mysql
(If you don't have it already) wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.2.4.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
(If you don't have it already) wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.2.3.RELEASE/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar
cf push cloud-nativedevelopment-dataflow-server --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.2.4.RELEASE.jar
cf bind-service cloud-nativedevelopment-dataflow-server cloud-nativedevelopment-scdf-redis
cf bind-service cloud-nativedevelopment-dataflow-server cloud-nativedevelopment-scdf-rabbit
cf bind-service cloud-nativedevelopment-dataflow-server cloud-nativedevelopment-scdf-mysql
cf set-env cloud-nativedevelopment-dataflow-server MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES cloud-nativedevelopment-scdf-rabbit
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION false
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES cloud-nativedevelopment-scdf-redis,cloud-nativedevelopment-scdf-rabbit
Setting Env for Username and Password silently
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME ********* > /dev/null
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD ********* > /dev/null
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG cloud-native
cf set-env cloud-nativedevelopment-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE development

Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)

....

NOTE: You will need a paid account to run this (25 GB of available application memory). **Do not leave this running**. Use the clean up script to delete the Server and its servers.

```
Upon successful completetion of the script, a Spring Cloud Data Flow server will be running on PWS.

![alt text](images/app-console.png "PCF App Console")

The dashboard will provide information about the Streams running and other useful details about the state of the Spring Cloud Data Flow Server (http://luke-dataflow-server.cfapps.io/dashboard)

![alt text](images/dashboard.png "Dashboard")

### Connecting To The Running Server

Next step is too connect a locally running Spring Cloud Shell to the running server to create the famous TickTock stream. To do this start the Shell application locally and use the `dataflow config server` command to connect to the server.

```shell

➜  spring-cloud-data-flow-setup git:(master) java -jar shell/spring-cloud-dataflow-shell-1.2.3.RELEASE.jar  
  ____                              ____ _                __
 / ___| _ __  _ __(_)_ __   __ _   / ___| | ___  _   _  __| |
 \___ \| '_ \| '__| | '_ \ / _` | | |   | |/ _ \| | | |/ _` |
  ___) | |_) | |  | | | | | (_| | | |___| | (_) | |_| | (_| |
 |____/| .__/|_|  |_|_| |_|\__, |  \____|_|\___/ \__,_|\__,_|
  ____ |_|    _          __|___/                 __________
 |  _ \  __ _| |_ __ _  |  ___| | _____      __  \ \ \ \ \ \
 | | | |/ _` | __/ _` | | |_  | |/ _ \ \ /\ / /   \ \ \ \ \ \
 | |_| | (_| | || (_| | |  _| | | (_) \ V  V /    / / / / / /
 |____/ \__,_|\__\__,_| |_|   |_|\___/ \_/\_/    /_/_/_/_/_/

1.2.3.RELEASE

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
server-unknown:>

```
Now we can connect to the Server

```shell

server-unknown:>dataflow config server https://cloud-nativedevelopment-dataflow-server.cfapps.io
Successfully targeted https://cloud-nativedevelopment-dataflow-server.cfapps.io
dataflow:>

```
Your server name will not the same as mine (its based on the Org and Space).

Next we will import the sources, sinks and processors handled by Spring Cloud Dataflow App Starters. Execute the command
from dataflow:

```shell
dataflow:>app import http://bit.ly/Bacon-RELEASE-stream-applications-rabbit-maven
Successfully registered 59 applications from [source.sftp, source.file.metadata, processor.tcp-client, source.s3.metadata, source.jms, source.ftp, processor.transform.metadata, source.time, sink.s3.metadata, sink.log, processor.scriptable-transform, source.load-generator, sink.websocket.metadata, source.syslog, processor.transform, sink.task-launcher-local.metadata, source.loggregator.metadata, source.s3, source.load-generator.metadata, processor.pmml.metadata, source.loggregator, source.tcp.metadata, processor.httpclient.metadata, sink.file.metadata, source.triggertask, source.twitterstream, source.gemfire-cq.metadata, processor.aggregator.metadata, source.mongodb, source.time.metadata, sink.counter.metadata, source.gemfire-cq, source.http, sink.tcp.metadata, sink.pgcopy.metadata, source.rabbit, sink.task-launcher-yarn, source.jms.metadata, sink.gemfire.metadata, sink.cassandra.metadata, processor.tcp-client.metadata, sink.throughput, processor.header-enricher, sink.task-launcher-local, sink.aggregate-counter.metadata, sink.mongodb, sink.log.metadata, processor.splitter, sink.hdfs-dataset, source.tcp, source.trigger, source.mongodb.metadata, processor.bridge, source.http.metadata, sink.ftp, source.rabbit.metadata, sink.jdbc, source.jdbc.metadata, sink.rabbit.metadata, sink.aggregate-counter, processor.pmml, sink.router.metadata, sink.cassandra, source.tcp-client.metadata, processor.filter.metadata, processor.groovy-transform, processor.header-enricher.metadata, source.ftp.metadata, sink.router, sink.redis-pubsub, source.tcp-client, processor.httpclient, sink.file, sink.websocket, sink.s3, source.syslog.metadata, sink.rabbit, sink.counter, sink.gpfdist.metadata, source.mail.metadata, source.trigger.metadata, processor.filter, sink.pgcopy, sink.jdbc.metadata, sink.gpfdist, sink.ftp.metadata, processor.splitter.metadata, sink.sftp, sink.field-value-counter, processor.groovy-filter.metadata, source.triggertask.metadata, sink.hdfs, processor.groovy-filter, sink.redis-pubsub.metadata, source.sftp.metadata, sink.field-value-counter.metadata, processor.bridge.metadata, processor.groovy-transform.metadata, processor.aggregator, sink.sftp.metadata, sink.throughput.metadata, sink.hdfs-dataset.metadata, sink.tcp, sink.task-launcher-cloudfoundry.metadata, source.mail, source.gemfire.metadata, source.jdbc, sink.task-launcher-yarn.metadata, sink.gemfire, source.gemfire, sink.hdfs.metadata, source.twitterstream.metadata, processor.tasklaunchrequest-transform, sink.task-launcher-cloudfoundry, source.file, sink.mongodb.metadata, processor.tasklaunchrequest-transform.metadata, processor.scriptable-transform.metadata]
dataflow:>

```
To learn more about the Starters, check out the following:
https://cloud.spring.io/spring-cloud-stream-app-starters/

To see the components that have been registered.

```shell

dataflow:>app list

╔══════════════╤═══════════════════════════╤══════════════════════════╤════╗
║    source    │         processor         │           sink           │task║
╠══════════════╪═══════════════════════════╪══════════════════════════╪════╣
║file          │aggregator                 │aggregate-counter         │    ║
║ftp           │bridge                     │cassandra                 │    ║
║gemfire       │filter                     │counter                   │    ║
║gemfire-cq    │groovy-filter              │field-value-counter       │    ║
║http          │groovy-transform           │file                      │    ║
║jdbc          │header-enricher            │ftp                       │    ║
║jms           │httpclient                 │gemfire                   │    ║
║load-generator│pmml                       │gpfdist                   │    ║
║loggregator   │scriptable-transform       │hdfs                      │    ║
║mail          │splitter                   │hdfs-dataset              │    ║
║mongodb       │tasklaunchrequest-transform│jdbc                      │    ║
║rabbit        │tcp-client                 │log                       │    ║
║s3            │transform                  │mongodb                   │    ║
║sftp          │                           │pgcopy                    │    ║
║syslog        │                           │rabbit                    │    ║
║tcp           │                           │redis-pubsub              │    ║
║tcp-client    │                           │router                    │    ║
║time          │                           │s3                        │    ║
║trigger       │                           │sftp                      │    ║
║triggertask   │                           │task-launcher-cloudfoundry│    ║
║twitterstream │                           │task-launcher-local       │    ║
║              │                           │task-launcher-yarn        │    ║
║              │                           │tcp                       │    ║
║              │                           │throughput                │    ║
║              │                           │websocket                 │    ║
╚══════════════╧═══════════════════════════╧══════════════════════════╧════╝


```
As you can see, lots of great components here.

To list the streams (none have been defined yet in this example)

```shell
dataflow:>stream list
╔═══════════╤═════════════════╤══════╗
║Stream Name│Stream Definition│Status║
╚═══════════╧═════════════════╧══════╝

dataflow:>
```
Our 'Hello World' will be the infamous 'ticktock' stream. It has two components. One that writes out the time another that writes that time to the log file. RabbitMQ is used to pass the time value as a message to the logging componet.

To create the stream, run the following:

```shell

dataflow:>stream create luketicktock --definition "time | log" --deploy
Created new stream 'luketicktock'
Deployment request has been sent
dataflow:>

```
The stream can now be seen in the UI:

![alt text](images/pcf-admin-ui-stream.png "PCF Admin UI Stream")

In the apps console we can see a Micro Service (Spring Boot) for each task in the stream has been deployed and given a route. They are also bound to the Rabbit Service as their backing data store.

![alt text](images/deployedstream.png "Microservices In PCF")

We can now see the result of the stream showing up in the Micro Service for the logging step of the flow

![alt text](images/pcf-tail-logs.png "PCF Log Tail")

New streams can be created using the dashboard, if you are not a fan of the Shell.

![alt text](images/flo-ui.png "New Streams")

Only the sources and sinks that are registered with the server will show up in the palette. Custom apps can be registered.

## Next Steps

This gets you started. Stay tuned for a more interesting example using this set up.

# References

http://cloud.spring.io/spring-cloud-dataflow/

https://github.com/spring-projects/spring-integration-java-dsl/wiki/spring-integration-java-dsl-reference
