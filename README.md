# Spring Cloud Data Flow Set Up

This is a simple demo to help you get up and running using Spring Cloud Data Flow (SCDF) on Pivotal Web Services (PWS). In this repo you will find:

1. Steps to get a SCDF Server running in PWS
2. Set Up the SCDF Shell locally
3. Get a 'Hello World' equivilant going for SCDF

## Setting Up The SCDF Server

The following steps need to be completed to get the server set up to submit Spring Cloud Data Flow streams.

1. Download the Spring Cloud Server project
2. Download the Spring Cloud Shell project
3. Create a Redis Service in PCF
4. Create a Rabbit Service in PCF
5. Push the Server project into PCF
6. Set up environmental variables for the Server to integrate with the elastic runtime of PCF
7. Start the Server

Running pws-scdf-setup.sh will perform all the steps on PWS (run.pivotal.io). The script will prompt for the organization, space, username and password as arguements.

```shell
./pws-scdf-setup.sh
```
Upon successful completetion of the script, a Spring Cloud Data Flow server will be running on PWS.

![alt text](images/app-console.png "PCF App Console")

The dashboard will provide information about the Streams running and other useful details about the state of the Spring Cloud Data Flow Server (http://luke-dataflow-server.cfapps.io/dashboard)

![alt text](images/dashboard.png "Dashboard")

### Connecting To The Running Server

Next step is too connect a locally running Spring Cloud Shell to the running server to create the famous TickTock stream. To do this start the Shell application locally and use the `dataflow config server` command to connect to the server.

```shell
➜  spring-cloud-data-flow-demo git:(master) ✗ java -jar spring-cloud-dataflow-shell-1.0.1.RELEASE.jar
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

1.0.1.RELEASE

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
server-unknown:>dataflow config server http://luke-dataflow-server.cfapps.io/
Successfully targeted http://luke-dataflow-server.cfapps.io/
dataflow:>

```

Next we perform the following steps:

0. Register maven repos
1. Register the sources
2. Register the sinks
3. Register the processors
3. Create a simple test stream

The command to register maven is:
- cf set-env luke-dataflow-server MAVEN_REMOTE_REPOSITORIES_REPO1_URL https://repo.spring.io/libs-snapshot

The commands to registers the sources, sinks and processors is handled
by Spring Cloud Dataflow App Starters.  Simply execute the command
from dataflow:

Once the shell is connected, a command file can be executed like this.

```shell
dataflow> app import http://bit.ly/Bacon-RELEASE-stream-applications-rabbit-maven 
Successfully registered applications: [sink.task-launcher-yarn, source.tcp, sink.jdbc, source.http, sink.rabbit, source.rabbit, source.ftp, sink.gpfdist, processor.transform, source.loggregator, source.sftp, processor.filter, source.file, sink.cassandra, processor.groovy-filter, sink.router, source.trigger, sink.hdfs-dataset, processor.splitter, source.load-generator, sink.sftp, sink.file, processor.tcp-client, source.time, source.gemfire, source.twitterstream, sink.tcp, source.jdbc, sink.field-value-counter, sink.redis-pubsub, sink.hdfs, sink.task-launcher-local, processor.bridge, processor.pmml, processor.httpclient, sink.ftp, source.s3, sink.log, sink.gemfire, sink.aggregate-counter, sink.throughput, source.triggertask, sink.s3, source.gemfire-cq, source.jms, source.tcp-client, processor.scriptable-transform, sink.counter, sink.websocket, source.mongodb, source.mail, processor.groovy-transform, source.syslog]
```
To see the apps

```shell
dataflow:>app  list
╔══════════════╤════════════════╤═══════════════════╤════╗
║    source    │   processor    │       sink        │task║
╠══════════════╪════════════════╪═══════════════════╪════╣
║file          │bridge          │aggregate-counter  │    ║
║ftp           │filter          │cassandra          │    ║
║http          │groovy-filter   │counter            │    ║
║jdbc          │groovy-transform│field-value-counter│    ║
║jms           │httpclient      │file               │    ║
║load-generator│pmml            │ftp                │    ║
║rabbit        │splitter        │gemfire            │    ║
║sftp          │transform       │gpfdist            │    ║
║tcp           │                │hdfs               │    ║
║time          │                │jdbc               │    ║
║              │                │log                │    ║
╚══════════════╧════════════════╧═══════════════════╧════╝

```

To list the streams (none have been defined yet in this example)

```shell
dataflow:>stream list
╔═══════════╤═════════════════╤══════╗
║Stream Name│Stream Definition│Status║
╚═══════════╧═════════════════╧══════╝

dataflow:>
```
To register the famous TickTock stream as an example, run the following

```shell
dataflow:>stream create luketicktock --definition "time | log" --deploy
Created and deployed new stream 'ticktock'
dataflow:>

```
The stream can now be seen in the UI

![alt text](images/pcf-admin-ui-stream.png "PCF Admin UI Stream")

In the apps console we can see a Micro Service (Spring Boot) for each task in the stream has been deployed and given a route. They are also bound to the Rabbit and Redis services.

![alt text](images/deployedstream.png "Microservices In PCF")

We can now see the result of the stream showing up in the Micro Service for the logging step of the flow

![alt text](images/pcf-tail-logs.png "PCF Log Tail")

New streams can be created using the dashboard.

![alt text](images/flo-ui.png "New Streams")

Only the sources and sinks that are registered with the server will show up in the palette. Custom apps can be registered.

# References

http://cloud.spring.io/spring-cloud-dataflow/

https://github.com/spring-projects/spring-integration-java-dsl/wiki/spring-integration-java-dsl-reference
