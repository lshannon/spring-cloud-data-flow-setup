package com.lukeshannon.springcloud.cli;

import org.springframework.boot.Banner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.dataflow.shell.EnableDataFlowShell;

@EnableDataFlowShell
@SpringBootApplication
public class SpringCloudCliApplication {

	public static void main(String[] args) {
		new SpringApplicationBuilder()
		.sources(SpringCloudCliApplication.class)
		.bannerMode(Banner.Mode.OFF)
		.run(args);
	}
}
