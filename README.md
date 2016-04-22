# Spring Cloud Data Flow Demo
This is a simple set of examples to explore Spring Cloud Data Flow.

These will build over time.

_NOTE_
These examples were built prior to a GA release of the project. As a result their our steps taken when working with a http://start.spring.io/ generated project that will most likely not be required to be taken after the project is GA.

## Server and DSL Example

With Spring XD it was easy to create flows that resulting in data moving from a source to a sink by taking advantage of:

- Spring Data
- Spring Integration
- Spring Batch

The Spring XD DSL made it possible to leaverage the power of these projects without needing to work with these projects directly. This opens the door for now Java developers to create flows.

The following is an demo of the Simple Tick Tock flow used to demo Spring XD, but using Spring Cloud Data Flows.

## Requirements

Redis is required. There is a version of Redis in the Spring Cloud Data Flow project, or if an a Mac it can be installed using Brew:

http://jasdeep.ca/2012/05/installing-redis-on-mac-os-x/

## Starting Redis

```shell

➜  SpringCloudServer git:(master) ✗ redis-server
80560:C 21 Apr 17:36:35.261 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
80560:M 21 Apr 17:36:35.262 * Increased maximum number of open files to 10032 (it was originally set to 256).
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.0.7 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 80560
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

80560:M 21 Apr 17:36:35.263 # Server started, Redis version 3.0.7
80560:M 21 Apr 17:36:35.263 * The server is now ready to accept connections on port 6379

```

## Start the Server project

```shell

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

2016-04-21 17:39:44.695  INFO 80595 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Fetching config from server at: http://localhost:8888
2016-04-21 17:39:44.816  WARN 80595 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Could not locate PropertySource: I/O error on GET request for "http://localhost:8888/spring-cloud-dataflow-server-local/default": Connection refused; nested exception is java.net.ConnectException: Connection refused
2016-04-21 17:39:44.817  INFO 80595 --- [           main] c.l.s.SpringCloudServerApplication       : No active profile set, falling back to default profiles: default
2016-04-21 17:39:44.827  INFO 80595 --- [           main] ationConfigEmbeddedWebApplicationContext : Refreshing org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@69bc62e9: startup date [Thu Apr 21 17:39:44 EDT 2016]; parent: org.springframework.context.annotation.AnnotationConfigApplicationContext@58ef44f5

....Output trimmed for brevity....

2016-04-21 17:39:51.251  INFO 80595 --- [           main] o.s.i.monitor.IntegrationMBeanExporter   : Registering MessageChannel errorChannel
2016-04-21 17:39:51.252  INFO 80595 --- [           main] o.s.i.monitor.IntegrationMBeanExporter   : Located managed bean 'org.springframework.integration:type=MessageChannel,name=errorChannel': registering with JMX server as MBean [org.springframework.integration:type=MessageChannel,name=errorChannel]
2016-04-21 17:39:51.293  INFO 80595 --- [           main] o.s.i.monitor.IntegrationMBeanExporter   : Located managed bean 'org.springframework.integration:type=MessageHandler,name=errorLogger,bean=internal': registering with JMX server as MBean [org.springframework.integration:type=MessageHandler,name=errorLogger,bean=internal]
2016-04-21 17:39:51.450  INFO 80595 --- [           main] o.s.c.support.DefaultLifecycleProcessor  : Starting beans in phase 0
2016-04-21 17:39:51.470  INFO 80595 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : Adding {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
2016-04-21 17:39:51.471  INFO 80595 --- [           main] o.s.i.channel.PublishSubscribeChannel    : Channel 'spring-cloud-dataflow-server-local:9393.errorChannel' has 1 subscriber(s).
2016-04-21 17:39:51.471  INFO 80595 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : started _org.springframework.integration.errorLogger
2016-04-21 17:39:51.549  INFO 80595 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 9393 (http)
2016-04-21 17:39:51.553  INFO 80595 --- [           main] c.l.s.SpringCloudServerApplication       : Started SpringCloudServerApplication in 7.921 seconds (JVM running for 8.421)

```

### Configuration

The file META-INF/applications.properties is required.

start.spring.io did not create this file at the time this example was created. This file needs to be manually created, and then the following entries added to it:

```java

source.file=maven://org.springframework.cloud.stream.module:file-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.ftp=maven://org.springframework.cloud.stream.module:ftp-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.jdbc=maven://org.springframework.cloud.stream.module:jdbc-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.jms=maven://org.springframework.cloud.stream.module:jms-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.http=maven://org.springframework.cloud.stream.module:http-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.load-generator=maven://org.springframework.cloud.stream.module:load-generator-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.rabbit=maven://org.springframework.cloud.stream.module:rabbit-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.sftp=maven://org.springframework.cloud.stream.module:sftp-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.tcp=maven://org.springframework.cloud.stream.module:tcp-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.time=maven://org.springframework.cloud.stream.module:time-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.trigger=maven://org.springframework.cloud.stream.module:trigger-source:jar:exec:1.0.0.BUILD-SNAPSHOT
source.twitterstream=maven://org.springframework.cloud.stream.module:twitterstream-source:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.bridge=maven://org.springframework.cloud.stream.module:bridge-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.filter=maven://org.springframework.cloud.stream.module:filter-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.groovy-filter=maven://org.springframework.cloud.stream.module:groovy-filter-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.groovy-transform=maven://org.springframework.cloud.stream.module:groovy-transform-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.httpclient=maven://org.springframework.cloud.stream.module:httpclient-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.pmml=maven://org.springframework.cloud.stream.module:pmml-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.splitter=maven://org.springframework.cloud.stream.module:splitter-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
processor.transform=maven://org.springframework.cloud.stream.module:transform-processor:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.aggregate-counter=maven://org.springframework.cloud.stream.module:aggregate-counter-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.cassandra=maven://org.springframework.cloud.stream.module:cassandra-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.counter=maven://org.springframework.cloud.stream.module:counter-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.field-value-counter=maven://org.springframework.cloud.stream.module:field-value-counter-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.file=maven://org.springframework.cloud.stream.module:file-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.ftp=maven://org.springframework.cloud.stream.module:ftp-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.gemfire=maven://org.springframework.cloud.stream.module:gemfire-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.gpfdist=maven://org.springframework.cloud.stream.module:gpfdist-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.hdfs=maven://org.springframework.cloud.stream.module:hdfs-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.jdbc=maven://org.springframework.cloud.stream.module:jdbc-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.log=maven://org.springframework.cloud.stream.module:log-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.rabbit=maven://org.springframework.cloud.stream.module:rabbit-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.redis=maven://org.springframework.cloud.stream.module:redis-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.router=maven://org.springframework.cloud.stream.module:router-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.tcp=maven://org.springframework.cloud.stream.module:tcp-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.throughput=maven://org.springframework.cloud.stream.module:throughput-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
sink.websocket=maven://org.springframework.cloud.stream.module:websocket-sink:jar:exec:1.0.0.BUILD-SNAPSHOT
task.timestamp=maven://org.springframework.cloud.task.module:timestamp-task:jar:exec:1.0.0.BUILD-SNAPSHOT

```


Also create a resources/dataflow-server.yml file to configure the server.

![alt text](dataflow-yml.png "Yml File")

The values for this file can be taken from here:
https://github.com/spring-cloud/spring-cloud-dataflow/blob/master/spring-cloud-starter-dataflow-server-local/src/main/resources/dataflow-server.yml

After the server is started, the server UI can now be seen in on the port specified in the Yml file.

![alt text](admin-ui.png "Admin UI")

## Start the CLI

The CLI project was also created using start.spring.io. Upon starting it will try and connected to a locally running server.

```shell

➜  SpringCloudCLI git:(master) ✗ java -jar target/SpringCloudCLI.jar   
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
dataflow:>

```

The modules specified in the applications file can be seen (these are the ones registered in the applications.properties file).

```shell

dataflow:>module list
╔══════════════╤════════════════╤═══════════════════╤═════════╗
║    source    │   processor    │       sink        │  task   ║
╠══════════════╪════════════════╪═══════════════════╪═════════╣
║file          │bridge          │aggregate-counter  │timestamp║
║ftp           │filter          │cassandra          │         ║
║http          │groovy-filter   │counter            │         ║
║jdbc          │groovy-transform│custom-log         │         ║
║jms           │httpclient      │field-value-counter│         ║
║load-generator│pmml            │file               │         ║
║rabbit        │splitter        │ftp                │         ║
║sftp          │transform       │gemfire            │         ║
║tcp           │                │gpfdist            │         ║
║time          │                │hdfs               │         ║
║trigger       │                │jdbc               │         ║
║twitterstream │                │log                │         ║
║              │                │rabbit             │         ║
║              │                │redis              │         ║
║              │                │router             │         ║
║              │                │tcp                │         ║
║              │                │throughput         │         ║
║              │                │websocket          │         ║
╚══════════════╧════════════════╧═══════════════════╧═════════╝


```

## Create Good Ol TickTock

It would not be a Spring XD demo if Ticktock was not done.

In the shell create the following stream.

```shell

dataflow:>stream create ticktock --definition "time | log" --deploy
Created and deployed new stream 'ticktock'
dataflow:>

```

The deployed stream can be seen in the admin console:

![alt text](deployedstream.png "Admin UI")

## Running the example on PCF

To run this simple example on PCF the first step is to get the Service pushing up and running. To do this a Redis service needs to be created in the target Space. This can be created using the UI or the CLI.

![alt text](redisservice.png "Redis Service")

### Pushing The Server

The is already a manifest.yml file in place, so a `cf push` from the same directory will push the application up to PCF.

```shell
➜  SpringCloudServer git:(master) ✗ cf push
Using manifest file /Users/lshannon/Documents/spring-cloud-data-flow-demo/SpringCloudServer/manifest.yml

Updating app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...
OK

Using route spring-cloud-server.cfapps.io
Uploading spring-cloud-server...
Uploading app files from: /Users/lshannon/Documents/spring-cloud-data-flow-demo/SpringCloudServer/target/SpringCloudServer.jar
Uploading 1.8M, 142 files
Done uploading               
OK
Binding service redis-service to app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...
OK

Stopping app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...
OK

Starting app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...
Downloading java_buildpack...
Downloaded java_buildpack
Creating container
Successfully created container
Downloading app package...
Downloaded app package (47.6M)
Downloading build artifacts cache...
Downloaded build artifacts cache (109B)
Staging...
-----> Java Buildpack Version: v3.7 (offline) | https://github.com/cloudfoundry/java-buildpack.git#b07524d
-----> Downloading Open Jdk JRE 1.8.0_91 from https://download.run.pivotal.io/openjdk/trusty/x86_64/openjdk-1.8.0_91.tar.gz (found in cache)
       Expanding Open Jdk JRE to .java-buildpack/open_jdk_jre (1.1s)
-----> Downloading Open JDK Like Memory Calculator 2.0.2_RELEASE from https://download.run.pivotal.io/memory-calculator/trusty/x86_64/memory-calculator-2.0.2_RELEASE.tar.gz (found in cache)
       Memory Settings: -XX:MaxMetaspaceSize=64M -Xss995K -Xms382293K -XX:MetaspaceSize=64M -Xmx382293K
-----> Downloading Spring Auto Reconfiguration 1.10.0_RELEASE from https://download.run.pivotal.io/auto-reconfiguration/auto-reconfiguration-1.10.0_RELEASE.jar (found in cache)
Exit status 0
Staging complete
Uploading droplet, build artifacts cache...
Uploading build artifacts cache...
Uploading droplet...
Uploaded build artifacts cache (109B)
Uploaded droplet (93.1M)
Uploading complete

0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
0 of 1 instances running, 1 starting
1 of 1 instances running

App started


OK

App spring-cloud-server was started using this command `CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-2.0.2_RELEASE -memorySizes=metaspace:64m.. -memoryWeights=heap:75,metaspace:10,native:10,stack:5 -memoryInitials=heap:100%,metaspace:100% -totMemory=$MEMORY_LIMIT) && JAVA_OPTS="-Djava.io.tmpdir=$TMPDIR -XX:OnOutOfMemoryError=$PWD/.java-buildpack/open_jdk_jre/bin/killjava.sh $CALCULATED_MEMORY" && SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.JarLauncher`

Showing health and status for app spring-cloud-server in org Northeast / Canada / space luke as lshannon@pivotal.io...
OK

requested state: started
instances: 1/1
usage: 512M x 1 instances
urls: spring-cloud-server.cfapps.io
last uploaded: Fri Apr 22 18:31:04 UTC 2016
stack: cflinuxfs2
buildpack: java_buildpack

     state     since                    cpu    memory         disk         details   
#0   running   2016-04-22 02:31:54 PM   0.0%   880K of 512M   1.3M of 1G      
```
The application will then be viewed and managed from the app console

![alt text](app-console.png "PCF App Console")

Unsurprisingly the admin-ui looks exactly same as it did locally (http://spring-cloud-server.cfapps.io/admin-ui/index.html#/streams/definitions)

![alt text](pcf-admin-ui.png "PCF Admin UI")

## Registering A Custom Module

To create a custom module, the following steps can be followed.
```shell
dataflow:>module register --name custom-log --type sink --uri maven://com.lukeshannon.springcloud:SpringCloudLoggingSink
Successfully registered module 'sink:custom-log'
```





# References

http://cloud.spring.io/spring-cloud-dataflow/

https://github.com/spring-projects/spring-integration-java-dsl/wiki/spring-integration-java-dsl-reference
