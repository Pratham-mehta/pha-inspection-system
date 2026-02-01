package com.pha.inspection.service;

import com.pha.inspection.model.dto.CreateResponseRequest;
import com.pha.inspection.model.dto.ResponseDTO;
import com.pha.inspection.model.entity.InspectionResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
 * Response Service
 * Handles inspection response CRUD and validation with DynamoDB persistence
 *
 * Storage Pattern:
 * - PK: "INSPECTION#{soNumber}"
 * - SK: "RESPONSE#{itemId}"
 */
@Service
public class ResponseService {

    private static final Logger logger = LoggerFactory.getLogger(ResponseService.class);

    private final DynamoDbTable<InspectionResponse> responseTable;

    @Autowired
    public ResponseService(DynamoDbEnhancedClient enhancedClient,
                          @Value("${aws.dynamodb.table-name}") String tableName) {
        this.responseTable = enhancedClient.table(tableName, TableSchema.fromBean(InspectionResponse.class));
    }

    /**
     * Get all responses for an inspection
     * Uses DynamoDB Query with PK = "INSPECTION#{soNumber}" and SK begins_with "RESPONSE#"
     */
    public List<ResponseDTO> getResponsesBySoNumber(String soNumber) {
        logger.info("Getting responses for SO: {}", soNumber);

        try {
            QueryEnhancedRequest query = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.sortBeginsWith(
                            Key.builder()
                                    .partitionValue("INSPECTION#" + soNumber)
                                    .sortValue("RESPONSE#")
                                    .build()))
                    .build();

            List<InspectionResponse> responses = responseTable.query(query).items().stream()
                    .collect(Collectors.toList());

            return responses.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error getting responses for SO: {}", soNumber, e);
            return new ArrayList<>();
        }
    }

    /**
     * Get single response by SO number and item ID
     * Uses DynamoDB GetItem with composite key
     */
    public Optional<ResponseDTO> getResponse(String soNumber, String itemId) {
        logger.info("Getting response for SO: {}, itemId: {}", soNumber, itemId);

        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTION#" + soNumber)
                    .sortValue("RESPONSE#" + itemId)
                    .build();

            InspectionResponse response = responseTable.getItem(key);
            return Optional.ofNullable(response).map(this::convertToDTO);
        } catch (Exception e) {
            logger.error("Error getting response for SO: {}, itemId: {}", soNumber, itemId, e);
            return Optional.empty();
        }
    }

    /**
     * Create or update response
     * Uses DynamoDB PutItem
     */
    public ResponseDTO saveResponse(String soNumber, CreateResponseRequest request) {
        logger.info("Saving response for SO: {}, itemId: {}, response: {}",
                soNumber, request.getItemId(), request.getResponse());

        try {
            // Validate response type
            if (!isValidResponseType(request.getResponse())) {
                throw new IllegalArgumentException("Invalid response type. Must be 'OK', 'NA', or 'Def'");
            }

            // Validate deficiency fields if response is "Def"
            if ("Def".equals(request.getResponse())) {
                validateDeficiencyFields(request);
            }

            // Create or update response
            InspectionResponse response = new InspectionResponse(soNumber, request.getItemId(), request.getResponse());
            response.setScopeOfWork(request.getScopeOfWork());
            response.setMaterialRequired(request.getMaterialRequired() != null ? request.getMaterialRequired() : false);
            response.setMaterialDescription(request.getMaterialDescription());
            response.setServiceId(request.getServiceId());
            response.setActivityCode(request.getActivityCode());
            response.setTenantCharge(request.getTenantCharge() != null ? request.getTenantCharge() : false);
            response.setUrgent(request.getUrgent() != null ? request.getUrgent() : false);
            response.setRrp(request.getRrp() != null ? request.getRrp() : false);
            response.setCreatedAt(Instant.now().toString());

            // Note: PK and SK are already set by the constructor
            // Store response in DynamoDB
            responseTable.putItem(response);

            logger.info("Response saved successfully to DynamoDB");
            return convertToDTO(response);
        } catch (IllegalArgumentException e) {
            logger.error("Validation error: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.error("Error saving response for SO: {}, itemId: {}", soNumber, request.getItemId(), e);
            throw new RuntimeException("Error saving response", e);
        }
    }

    /**
     * Delete response
     * Uses DynamoDB DeleteItem
     */
    public boolean deleteResponse(String soNumber, String itemId) {
        logger.info("Deleting response for SO: {}, itemId: {}", soNumber, itemId);

        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTION#" + soNumber)
                    .sortValue("RESPONSE#" + itemId)
                    .build();

            responseTable.deleteItem(key);
            logger.info("Response deleted successfully from DynamoDB");
            return true;
        } catch (Exception e) {
            logger.error("Error deleting response for SO: {}, itemId: {}", soNumber, itemId, e);
            return false;
        }
    }

    /**
     * Validate response type
     */
    private boolean isValidResponseType(String response) {
        return "OK".equals(response) || "NA".equals(response) || "Def".equals(response);
    }

    /**
     * Validate deficiency fields
     */
    private void validateDeficiencyFields(CreateResponseRequest request) {
        List<String> errors = new ArrayList<>();

        if (request.getScopeOfWork() == null || request.getScopeOfWork().trim().isEmpty()) {
            errors.add("Scope of work is required for deficiency responses");
        }

        if (request.getServiceId() == null || request.getServiceId().trim().isEmpty()) {
            errors.add("Service ID is required for deficiency responses");
        }

        if (request.getActivityCode() == null || request.getActivityCode().trim().isEmpty()) {
            errors.add("Activity code is required for deficiency responses");
        }

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException("Validation errors: " + String.join(", ", errors));
        }
    }

    /**
     * Convert entity to DTO
     */
    private ResponseDTO convertToDTO(InspectionResponse response) {
        ResponseDTO dto = new ResponseDTO();
        dto.setItemId(response.getItemId());
        dto.setResponse(response.getResponse());
        dto.setScopeOfWork(response.getScopeOfWork());
        dto.setMaterialRequired(response.getMaterialRequired());
        dto.setMaterialDescription(response.getMaterialDescription());
        dto.setServiceId(response.getServiceId());
        dto.setActivityCode(response.getActivityCode());
        dto.setTenantCharge(response.getTenantCharge());
        dto.setUrgent(response.getUrgent());
        dto.setRrp(response.getRrp());
        dto.setCreatedAt(response.getCreatedAt());
        return dto;
    }
}
