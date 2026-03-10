package com.pha.inspection.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.bedrockagentruntime.BedrockAgentRuntimeClient;
import software.amazon.awssdk.services.bedrockagentruntime.model.*;

@Service
public class ChatbotService {

    private static final Logger logger = LoggerFactory.getLogger(ChatbotService.class);

    private final BedrockAgentRuntimeClient bedrockClient;

    @Value("${bedrock.knowledge-base-id}")
    private String knowledgeBaseId;

    @Value("${bedrock.model-arn}")
    private String modelArn;

    public ChatbotService(BedrockAgentRuntimeClient bedrockClient) {
        this.bedrockClient = bedrockClient;
    }

    public String query(String question) {
        logger.info("Chatbot query: {}", question);

        RetrieveAndGenerateRequest request = RetrieveAndGenerateRequest.builder()
                .input(RetrieveAndGenerateInput.builder()
                        .text(question)
                        .build())
                .retrieveAndGenerateConfiguration(RetrieveAndGenerateConfiguration.builder()
                        .type(RetrieveAndGenerateType.KNOWLEDGE_BASE)
                        .knowledgeBaseConfiguration(KnowledgeBaseRetrieveAndGenerateConfiguration.builder()
                                .knowledgeBaseId(knowledgeBaseId)
                                .modelArn(modelArn)
                                .build())
                        .build())
                .build();

        RetrieveAndGenerateResponse response = bedrockClient.retrieveAndGenerate(request);
        String answer = response.output().text();

        logger.info("Chatbot response received, length: {}", answer.length());
        return answer;
    }
}
