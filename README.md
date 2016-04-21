# Spring Cloud Data Flow Demo
This is a simple set of examples to explore Spring Cloud Data Flow.

These will build over time.

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

Now the admin UI can be viewed locally.

![alt text](admin-ui.png "Admin UI")

## Start the CLI

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

Out of the box there are not any modules:

```shell

Welcome to the Spring Cloud Data Flow shell. For assistance hit TAB or type "help".
dataflow:>module list
╔══════╤═════════╤════╤════╗
║source│processor│sink│task║
╚══════╧═════════╧════╧════╝

```



# References

http://cloud.spring.io/spring-cloud-dataflow/

https://github.com/spring-projects/spring-integration-java-dsl/wiki/spring-integration-java-dsl-reference
