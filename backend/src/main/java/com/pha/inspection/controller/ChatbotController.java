package com.pha.inspection.controller;

import com.pha.inspection.service.ChatbotService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/chatbot")
@Tag(name = "Chatbot", description = "AI-powered chatbot using AWS Bedrock RAG")
@SecurityRequirement(name = "bearerAuth")
public class ChatbotController {

    private static final Logger logger = LoggerFactory.getLogger(ChatbotController.class);

    private final ChatbotService chatbotService;

    public ChatbotController(ChatbotService chatbotService) {
        this.chatbotService = chatbotService;
    }

    @PostMapping("/query")
    @Operation(summary = "Ask the chatbot a question", description = "Queries AWS Bedrock Knowledge Base using RAG pipeline")
    public ResponseEntity<?> query(@RequestBody Map<String, String> body) {
        String question = body.get("question");

        if (question == null || question.trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Question cannot be empty");
            return ResponseEntity.badRequest().body(error);
        }

        logger.info("POST /chatbot/query - question: {}", question);

        try {
            String answer = chatbotService.query(question.trim());
            Map<String, String> response = new HashMap<>();
            response.put("question", question.trim());
            response.put("answer", answer);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Chatbot query failed: {}", e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to get response from chatbot: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
