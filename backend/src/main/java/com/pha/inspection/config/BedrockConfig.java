package com.pha.inspection.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.bedrockagentruntime.BedrockAgentRuntimeClient;

@Configuration
public class BedrockConfig {

    @Value("${bedrock.access-key-id}")
    private String accessKeyId;

    @Value("${bedrock.secret-access-key}")
    private String secretAccessKey;

    @Value("${bedrock.region}")
    private String region;

    @Bean
    public BedrockAgentRuntimeClient bedrockAgentRuntimeClient() {
        return BedrockAgentRuntimeClient.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKeyId, secretAccessKey)
                ))
                .build();
    }
}
