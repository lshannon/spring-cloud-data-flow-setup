# Spring Cloud Data Flow Demo

This is a simple demo to explore Spring Cloud Data Flow working on Cloud Foundry to provide an experience similar to Spring XD.

## Overview

As with Spring XD we can leverage the DSL. Using the DSL it was easy to create flows that resulting in data moving from a source to a sink by taking advantage of:

- Spring Data
- Spring Integration
- Spring Batch

This can be done with minimal knowledge of these projects opening the door for none Java developers to create flows.

Flows, or streams, move data from a Source to a Sink, often with with processing or transformations in between.

An example might be:

FTP -> Transform Objects to JSON -> Filter on 'country=CA' -> HDFS

This stream would poll a FTP for files. Each row of a file would be converted to JSON. Only JSON where the attribute country was equal to 'CA' would then be written down to HDFS.

Using Spring Cloud Data Flow each step in this stream would become a application orchestrated by Pivotal Cloud Foundry.

### Setting Up The Server In PCF

The following steps need to be completed to get the server set up to submit Spring XD jobs.

1. Download the Spring Cloud Server project
2. Download the Spring Cloud Shell project
3. Create a Redis Service in PCF
4. Create a Rabbit Service in PCF
5. Push the Server project into PCF
6. Set up environmental variables for the Server to integrate with the elastic runtime of PCF
7. Start the Server

Running demo_setup_1.sh will perform all the steps on PWS (run.pivotal.io). The script needs the organization, space, username and password with permissions to create new applications.

```shell
./demo_setup_1.sh 'My Org' 'luke' 'email@mydomain.com' 'mypassword'
```

The application will then be viewed and managed from the app console

![alt text](app-console.png "PCF App Console")

The admin-ui will provide information about the Streams running and other useful details about the state of the Spring Cloud Data Flow Server.

![alt text](pcf-admin-ui.png "PCF Admin UI")

### Connecting To The Running Server

Next step is too connect the local CLI to the running server to create our awesome TickTock stream. To do this start the CLI application locally and use the `dataflow config server` command to connect to the server.

```shell

➜  SpringCloudCLI git:(master) java -jar target/SpringCloudCLI.jar                
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

1.0.0.BUILD-SNAPSHOT

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
server-unknown:>dataflow config server http://spring-cloud-server.cfapps.io/
Successfully targeted http://spring-cloud-server.cfapps.io/
dataflow:>
```

Next lets create the stream.

```shell
dataflow:>stream create ticktock --definition "time | log" --deploy
Created and deployed new stream 'ticktock'
dataflow:>
```

The stream can now be seen in the UI, just as it behaved locally. The strange this is it shows as `Undeployed` when the stream is infact running (as we will see in the logs)

![alt text](pcf-admin-ui-stream.png "PCF Admin UI Stream")

Now we can tail the log through the Web UI or using the PCF CLI to see the output of the stream.

```shell

➜  SpringCloudServer git:(master) ✗ cf logs spring-cloud-server
Connected, tailing logs for app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...

2016-04-22T15:11:17.96-0400 [RTR/1]      OUT spring-cloud-server.cfapps.io - [22/04/2016:19:11:17.955 +0000] "GET /streams/definitions?page=0&size=10 HTTP/1.1" 200 0 357 "http://spring-cloud-server.cfapps.io/admin-ui/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 10.10.2.176:51365 x_forwarded_for:"66.207.217.100" x_forwarded_proto:"http" vcap_request_id:d01c80d3-7eef-4045-49c7-a90295ea56a6 response_time:0.004617575 app_id:19b0383e-241b-4210-8887-5a1c834eff69
2016-04-22T15:11:17.99-0400 [RTR/1]      OUT spring-cloud-server.cfapps.io - [22/04/2016:19:11:17.993 +0000] "GET /streams/definitions?page=0&size=10 HTTP/1.1" 200 0 357 "http://spring-cloud-server.cfapps.io/admin-ui/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 10.10.2.176:51485 x_forwarded_for:"66.207.217.100" x_forwarded_proto:"http" vcap_request_id:9db16227-56e6-41e8-71c7-aabc8c577371 response_time:0.004307066 app_id:19b0383e-241b-4210-8887-5a1c834eff69
2016-04-22T15:11:18.00-0400 [RTR/4]      OUT spring-cloud-server.cfapps.io - [22/04/2016:19:11:18.004 +0000] "GET /streams/definitions?page=0&size=10 HTTP/1.1" 200 0 357 "http://spring-cloud-server.cfapps.io/admin-ui/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 10.10.2.176:39280 x_forwarded_for:"66.207.217.100" x_forwarded_proto:"http" vcap_request_id:ae08d534-9596-48e6-7381-e9bad2f820c3 response_time:0.003840506 app_id:19b0383e-241b-4210-8887-5a1c834eff69
2016-04-22T15:11:19.95-0400 [RTR/1]      OUT spring-cloud-server.cfapps.io - [22/04/2016:19:11:19.949 +0000] "GET /streams/definitions?page=0&size=10 HTTP/1.1" 200 0 357 "http://spring-cloud-server.cfapps.io/admin-ui/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36" 10.10.2.176:51485 x_forwarded_for:"66.207.217.100" x_forwarded_proto:"http" vcap_request_id:d16350ac-ee96-4fa1-7384-d2ef606ca05b response_time:0.003808166 app_id:19b0383e-241b-4210-8887-5a1c834eff69

.... and so on....

```

No-one has ever gotten a raise for logging the time to file, but in this case I think an exception should be made because this is cool!

Here is how things look in the Log tailing UI through the PCF apps console

![alt text](pcf-tail-logs.png "PCF Log Tail")

# References

http://cloud.spring.io/spring-cloud-dataflow/

https://github.com/spring-projects/spring-integration-java-dsl/wiki/spring-integration-java-dsl-reference
