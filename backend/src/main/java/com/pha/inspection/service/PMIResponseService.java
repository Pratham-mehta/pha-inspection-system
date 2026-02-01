package com.pha.inspection.service;

import com.pha.inspection.model.dto.CreatePMIResponseRequest;
import com.pha.inspection.model.dto.PMIResponseDTO;
import com.pha.inspection.model.entity.PMIResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryConditional;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryEnhancedRequest;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * PMI Response Service - DynamoDB Implementation
 * Handles PMI response CRUD operations
 */
@Service
public class PMIResponseService {

    private static final Logger logger = LoggerFactory.getLogger(PMIResponseService.class);

    private final DynamoDbTable<PMIResponse> pmiResponseTable;

    @Autowired
    public PMIResponseService(DynamoDbEnhancedClient dynamoDbEnhancedClient) {
        this.pmiResponseTable = dynamoDbEnhancedClient.table("pha-inspections", TableSchema.fromBean(PMIResponse.class));
        logger.info("PMIResponseService initialized with DynamoDB table: pha-inspections");
    }

    /**
     * Get all PMI responses for an inspection
     */
    public List<PMIResponseDTO> getResponsesBySoNumber(String soNumber) {
        logger.info("Getting PMI responses for SO: {}", soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;
            
            QueryEnhancedRequest queryRequest = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.keyEqualTo(Key.builder()
                            .partitionValue(pk)
                            .build()))
                    .build();

            List<PMIResponse> responses = pmiResponseTable.query(queryRequest).stream()
                    .flatMap(page -> page.items().stream())
                    .filter(response -> response.getSK() != null && response.getSK().startsWith("PMI#"))
                    .collect(Collectors.toList());

            logger.info("Found {} PMI responses for SO: {}", responses.size(), soNumber);

            return responses.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error getting PMI responses for SO: {}", soNumber, e);
            throw new RuntimeException("Failed to get PMI responses", e);
        }
    }

    /**
     * Get single PMI response by SO number and item ID
     */
    public Optional<PMIResponseDTO> getResponse(String soNumber, String itemId) {
        logger.info("Getting PMI response for SO: {}, itemId: {}", soNumber, itemId);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "PMI#" + itemId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            PMIResponse response = pmiResponseTable.getItem(key);
            
            if (response == null) {
                logger.info("PMI response not found for SO: {}, itemId: {}", soNumber, itemId);
                return Optional.empty();
            }

            logger.info("Found PMI response for SO: {}, itemId: {}", soNumber, itemId);
            return Optional.of(convertToDTO(response));
        } catch (Exception e) {
            logger.error("Error getting PMI response for SO: {}, itemId: {}", soNumber, itemId, e);
            throw new RuntimeException("Failed to get PMI response", e);
        }
    }

    /**
     * Create or update PMI response
     */
    public PMIResponseDTO saveResponse(String soNumber, CreatePMIResponseRequest request) {
        logger.info("Saving PMI response for SO: {}, itemId: {}, completed: {}",
                soNumber, request.getItemId(), request.getCompleted());

        // Validate required fields
        if (request.getItemId() == null || request.getItemId().trim().isEmpty()) {
            throw new IllegalArgumentException("Item ID is required");
        }

        if (request.getCategoryId() == null || request.getCategoryId().trim().isEmpty()) {
            throw new IllegalArgumentException("Category ID is required");
        }

        try {
            // Create or update response
            PMIResponse response = new PMIResponse(soNumber, request.getItemId(), request.getCategoryId());
            response.setCompleted(request.getCompleted() != null ? request.getCompleted() : false);
            response.setNotes(request.getNotes());
            response.setCreatedAt(Instant.now().toString());

            // Save to DynamoDB
            pmiResponseTable.putItem(response);

            logger.info("PMI response saved successfully to DynamoDB");
            return convertToDTO(response);
        } catch (Exception e) {
            logger.error("Error saving PMI response for SO: {}, itemId: {}", soNumber, request.getItemId(), e);
            throw new RuntimeException("Failed to save PMI response", e);
        }
    }

    /**
     * Delete PMI response
     */
    public boolean deleteResponse(String soNumber, String itemId) {
        logger.info("Deleting PMI response for SO: {}, itemId: {}", soNumber, itemId);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "PMI#" + itemId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            PMIResponse deleted = pmiResponseTable.deleteItem(key);
            
            boolean success = deleted != null;
            if (success) {
                logger.info("PMI response deleted successfully from DynamoDB");
            } else {
                logger.warn("PMI response not found for deletion");
            }
            
            return success;
        } catch (Exception e) {
            logger.error("Error deleting PMI response for SO: {}, itemId: {}", soNumber, itemId, e);
            throw new RuntimeException("Failed to delete PMI response", e);
        }
    }

    /**
     * Convert entity to DTO
     */
    private PMIResponseDTO convertToDTO(PMIResponse response) {
        PMIResponseDTO dto = new PMIResponseDTO();
        dto.setItemId(response.getItemId());
        dto.setCategoryId(response.getCategoryId());
        dto.setCompleted(response.getCompleted());
        dto.setNotes(response.getNotes());
        dto.setCreatedAt(response.getCreatedAt());
        return dto;
    }
}
