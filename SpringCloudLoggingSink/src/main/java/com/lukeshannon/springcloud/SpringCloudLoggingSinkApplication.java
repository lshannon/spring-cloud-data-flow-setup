package com.lukeshannon.springcloud;

import java.util.Map;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.messaging.Sink;
import org.springframework.integration.annotation.MessageEndpoint;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.handler.annotation.Headers;
import org.springframework.messaging.handler.annotation.Payload;

@SpringBootApplication
public class SpringCloudLoggingSinkApplication {
	
	@MessageEndpoint
	public static class LoggingMessageEndpoint {

		@ServiceActivator(inputChannel = Sink.INPUT)
		public void logIncomingMessages(
				@Payload String msg,
				@Headers Map<String, Object> headers) {

			System.out.println(msg);
			headers.entrySet().forEach(e ->
					System.out.println(e.getKey() + '=' + e.getValue()));

		}
	}

	public static void main(String[] args) {
		SpringApplication.run(SpringCloudLoggingSinkApplication.class, args);
	}
}
