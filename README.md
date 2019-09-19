# Introduction

Spring Cloud Data Flow (SCDF) provides a framework for creating, operating and monitoring data event streams:

https://cloud.spring.io/spring-cloud-dataflow/

To take advantage of this framework, a SCDF Server needs to be running (and integrated) with a supported platform. In the case of this sample, that runtime is PWS (a managed PCF running on AWS).

This is a quick sample to get the Spring Cloud Dataflow (SCDF) Server running on PWS.

The best option, if you host a PCF installation of your own, is to use the following tile. It sets up everything required and is kept in sync with the SCDF roadmap:

http://docs.pivotal.io/scdf/

For more information on running SCDF on PCF:

https://docs.spring.io/spring-cloud-dataflow-server-cloudfoundry/docs/1.3.0.RELEASE/reference/htmlsingle/#getting-started

## Setting Up The SCDF Server

The SCDF Server gets stream definitions submitted to it, its uses the platform its running in to orchestrate the applications that perform each step in the data pipeline.

The scripts in this project execute the following steps to get the Admin server running on PCF.

1. Download the SCDF Server Application (Spring Boot App)
2. Download the Spring Cloud Shell project (used to submit streams from a local machine to the Server)
3. Create a Redis Service in PCF (optional)
4. Create a Rabbit Service in PCF
5. Create a MySQL service (optional)
5. Push the Server project into PCF (stopped)
6. Set up environmental variables for the Server to integrate with the elastic runtime of PCF and Redis + Rabbit
7. Start the Server

### 3rd Party services

As listed above, a few services are created. The following is a quick review of what they are used for.

#### Rabbit (Required)

Data bus used to pass messages between services.

#### Redis (Optional)

Used for counters and in-memory analytics that can be collected as data flows through a streams. If not using analytics, this service is not required

#### MySql (Required)

Used for store batch data. If no DB is supplied, SCDF will use an embedded H2. H2 is not suitable for production work loads. Using a DB like MySQL or Postgres is required for production workloads.

### Setting Up On PWS

Running setup-pws.sh will perform all the steps on PWS (run.pivotal.io). The script will prompt for the organization, space, username and password as arguments. These are required for the server to be able to create and manage data streams.

The script will create an Admin Server instance based on a trimmed version the names of the Org and Space.

A preview of these commands to be ran to set up the Admin is previewed at the start of the script. This provides a chance to cancel if a mistake was made, or if doing something cool is too scary for you.

```shell

./setup-pws.sh

...

The Data Server will be called: cloudeve-dataflow-server
The following services will be created:
Redis Serivce: cloudeve-scdf-redis
Rabbit Service: cloudeve-scdf-rabbitmq
MySQL: cloudeve-scdf-mysql

The following commands will be ran to set up your Server:
cf create-service cloudamqp lemur cloudeve-scdf-rabbitmq
cf create-service rediscloud 30mb cloudeve-scdf-redis
cf create-service cleardb spark cloudeve-scdf-mysql
(If you don't have it already) wget http://repo.spring.io/libs-release/org/springframework/cloud/spring-cloud-dataflow-server-cloudfoundry/1.4.0.RELEASE/spring-cloud-dataflow-server-cloudfoundry-1.4.0.RELEASE.jar
(If you don't have it already) wget http://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/1.4.0.RELEASE/spring-cloud-dataflow-shell-1.4.0.RELEASE.jar
cf push cloudeve-dataflow-server --no-start -b java_buildpack -m 2G -k 2G --no-start -p server/spring-cloud-dataflow-server-cloudfoundry-1.4.0.RELEASE.jar
cf bind-service cloudeve-dataflow-server cloudeve-scdf-redis
cf bind-service cloudeve-dataflow-server cloudeve-scdf-rabbitmq
cf bind-service cloudeve-dataflow-server cloudeve-scdf-mysql
cf set-env cloudeve-dataflow-server MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL https://api.run.pivotal.io
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN cfapps.io
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES cloudeve-scdf-rabbitmq
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SERVICES cloudeve-scdf-redis,cloudeve-scdf-mysql
Setting Env for Username and Password silently
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME luke.shannon@gmail.com > /dev/null
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD ********* > /dev/null
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG cloud-native
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE development
cf set-env cloudeve-dataflow-server SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_API_TIMEOUT 500
cloudeve-dataflow-server

Do you wish to run these commands (there will be a charge for all these services in PWS)? (Type 'Y' to proceed)

....rest of script output omitted for brevity...it just does the commands above

```

NOTE: **Do not leave this SDCF Streams running in PWS unless they are serving a business purpose**. As PWS bills based on usage, a running stream can run up a serious bill. If you are doing this for learning, use the cleanup.sh script to delete the Server and its services once you are done with your stream.

Upon successful completion of the script, a Spring Cloud Data Flow server will be running on PWS.

![alt text](images/app-console.png "PCF App Console")

The dashboard will provide information about the Streams running and other useful details about the state of the Spring Cloud Data Flow Server (http://luke-dataflow-server.cfapps.io/dashboard)

![alt text](images/dashboard.png "Dashboard")

### Connecting To The Running Server

Next step is too connect a locally running Spring Cloud Shell to the running server to create the famous TickTock stream. To do this start the Shell application locally and use the `dataflow config server` command to connect to the server.

```shell
luke@luke-Precision-5510:~/source/spring-cloud-data-flow-setup$ java -jar shell/spring-cloud-dataflow-shell-1.7.3.RELEASE.jar --dataflow.mode=skipper
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

1.7.3.RELEASE

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
server-unknown:>

```
Now we can connect to the Server

```shell

server-unknown:>dataflow config server --uri https://scdfdeve-server.cfapps.io
Shell mode: skipper, Server mode: skipper
dataflow:>

```
Your server name will not the same as mine (its based on the Org and Space).

Next we will import the sources, sinks and processors handled by Spring Cloud Dataflow App Starters. Execute the command
from dataflow:

```shell
dataflow:>app import --uri http://bit.ly/Celsius-SR3-stream-applications-rabbit-maven
Successfully registered 65 applications from [source.sftp.metadata, sink.throughput.metadata, sink.cassandra.metadata, source.loggregator.metadata, source.s3, processor.aggregator.metadata, sink.hdfs, sink.rabbit, sink.ftp.metadata, processor.tasklaunchrequest-transform.metadata, sink.pgcopy, processor.httpclient, sink.jdbc, source.tcp, source.s3.metadata, sink.jdbc.metadata, sink.mongodb.metadata, sink.tcp.metadata, source.mqtt, source.gemfire.metadata, sink.hdfs-dataset, sink.gemfire.metadata, source.load-generator.metadata, sink.log, sink.redis-pubsub, sink.pgcopy.metadata, processor.python-http.metadata, sink.counter.metadata, processor.twitter-sentiment, sink.file.metadata, sink.s3.metadata, processor.python-http, sink.task-launcher-yarn, processor.tcp-client, sink.hdfs.metadata, sink.sftp.metadata, sink.tcp, source.sftp, source.http, sink.task-launcher-cloudfoundry.metadata, processor.groovy-filter.metadata, processor.splitter.metadata, source.syslog.metadata, source.file, processor.bridge, processor.tensorflow, sink.task-launcher-cloudfoundry, processor.tensorflow.metadata, sink.cassandra, processor.twitter-sentiment.metadata, processor.python-jython.metadata, source.time.metadata, source.tcp.metadata, sink.task-launcher-yarn.metadata, processor.transform.metadata, source.ftp.metadata, processor.scriptable-transform, source.triggertask.metadata, source.mqtt.metadata, source.jms.metadata, sink.task-launcher-local, source.syslog, source.file.metadata, processor.transform, source.time, processor.bridge.metadata, sink.s3, source.triggertask, source.gemfire-cq.metadata, source.trigger.metadata, source.jms, source.mail, sink.gpfdist.metadata, sink.mqtt.metadata, source.mongodb, source.rabbit, sink.router, source.ftp, sink.file, processor.groovy-transform.metadata, source.tcp-client, processor.scriptable-transform.metadata, processor.splitter, sink.gpfdist, source.gemfire, sink.redis-pubsub.metadata, source.load-generator, source.loggregator, processor.aggregator, processor.groovy-transform, processor.python-jython, sink.throughput, sink.hdfs-dataset.metadata, sink.ftp, processor.filter.metadata, sink.mqtt, source.trigger, sink.gemfire, processor.header-enricher.metadata, sink.sftp, processor.filter, source.jdbc, source.gemfire-cq, source.twitterstream, sink.rabbit.metadata, sink.field-value-counter, sink.websocket.metadata, processor.httpclient.metadata, sink.log.metadata, processor.tasklaunchrequest-transform, processor.tcp-client.metadata, sink.task-launcher-local.metadata, sink.websocket, source.jdbc.metadata, source.mail.metadata, source.rabbit.metadata, source.tcp-client.metadata, processor.pmml, sink.field-value-counter.metadata, sink.aggregate-counter.metadata, source.http.metadata, processor.groovy-filter, sink.counter, source.twitterstream.metadata, processor.header-enricher, sink.aggregate-counter, source.mongodb.metadata, processor.pmml.metadata, sink.router.metadata, sink.mongodb]

```
To learn more about the Starters, check out the following:
https://cloud.spring.io/spring-cloud-stream-app-starters/

To see the components that have been registered.

```shell
dataflow:>app list
╔═══╤══════════════╤═══════════════════════════╤══════════════════════════╤════╗
║app│    source    │         processor         │           sink           │task║
╠═══╪══════════════╪═══════════════════════════╪══════════════════════════╪════╣
║   │sftp          │tcp-client                 │mqtt                      │    ║
║   │jms           │scriptable-transform       │log                       │    ║
║   │ftp           │transform                  │task-launcher-yarn        │    ║
║   │time          │header-enricher            │throughput                │    ║
║   │load-generator│python-http                │task-launcher-local       │    ║
║   │syslog        │twitter-sentiment          │mongodb                   │    ║
║   │s3            │splitter                   │hdfs-dataset              │    ║
║   │loggregator   │bridge                     │ftp                       │    ║
║   │triggertask   │pmml                       │jdbc                      │    ║
║   │twitterstream │python-jython              │aggregate-counter         │    ║
║   │mongodb       │groovy-transform           │cassandra                 │    ║
║   │gemfire-cq    │httpclient                 │router                    │    ║
║   │http          │filter                     │redis-pubsub              │    ║
║   │rabbit        │groovy-filter              │file                      │    ║
║   │tcp           │aggregator                 │websocket                 │    ║
║   │trigger       │tensorflow                 │s3                        │    ║
║   │mqtt          │tasklaunchrequest-transform│rabbit                    │    ║
║   │tcp-client    │                           │counter                   │    ║
║   │mail          │                           │pgcopy                    │    ║
║   │jdbc          │                           │gpfdist                   │    ║
║   │gemfire       │                           │sftp                      │    ║
║   │file          │                           │field-value-counter       │    ║
║   │              │                           │hdfs                      │    ║
║   │              │                           │tcp                       │    ║
║   │              │                           │gemfire                   │    ║
║   │              │                           │task-launcher-cloudfoundry│    ║
╚═══╧══════════════╧═══════════════════════════╧══════════════════════════╧════╝
```
As you can see, lots of great components here.

There is a column here called 'app'. This is for the Stream Application DSL. This allows us to have an app that is a source and sink, meaning multiple inputs/multiple outputs:

https://docs.spring.io/spring-cloud-dataflow/docs/current/reference/htmlsingle/#spring-cloud-dataflow-stream-app-dsl

To list the streams (none have been defined yet in this example)

```shell
dataflow:>stream list

╔═══════════╤═════════════════╤══════╗
║Stream Name│Stream Definition│Status║
╚═══════════╧═════════════════╧══════╝

dataflow:>
```
Our 'Hello World' will be the infamous 'ticktock' stream. It has two components. One that writes out the time another that writes that time to the log file. RabbitMQ is used to pass the time value as a message to the logging component.

To create the stream, run the following:

```shell

dataflow:>stream create l1 --definition "time | log" --deploy
Created new stream 'luketicktock'
Deployment request has been sent
dataflow:>

```
The stream can now be seen in the UI:

![alt text](images/admin-stream-deployed.png "Deployed Stream")

In the apps console of PCF we can see a Micro Service (Spring Boot) for each task in the stream has been deployed and given a route. They are also bound to the Rabbit Service as their backing data store.

![alt text](images/deployed-micro-services.png "Microservices In PCF")

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
