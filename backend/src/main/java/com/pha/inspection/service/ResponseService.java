package com.pha.inspection.service;

import com.pha.inspection.model.dto.CreateResponseRequest;
import com.pha.inspection.model.dto.ResponseDTO;
import com.pha.inspection.model.entity.InspectionResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Response Service
 * Handles inspection response CRUD and validation
 */
@Service
public class ResponseService {

    private static final Logger logger = LoggerFactory.getLogger(ResponseService.class);

    // In-memory storage: Map<soNumber, Map<itemId, InspectionResponse>>
    private final Map<String, Map<String, InspectionResponse>> responseStore = new HashMap<>();

    /**
     * Get all responses for an inspection
     */
    public List<ResponseDTO> getResponsesBySoNumber(String soNumber) {
        logger.info("Getting responses for SO: {}", soNumber);

        Map<String, InspectionResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return new ArrayList<>();
        }

        return responses.values().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get single response by SO number and item ID
     */
    public Optional<ResponseDTO> getResponse(String soNumber, String itemId) {
        logger.info("Getting response for SO: {}, itemId: {}", soNumber, itemId);

        Map<String, InspectionResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return Optional.empty();
        }

        InspectionResponse response = responses.get(itemId);
        return Optional.ofNullable(response).map(this::convertToDTO);
    }

    /**
     * Create or update response
     */
    public ResponseDTO saveResponse(String soNumber, CreateResponseRequest request) {
        logger.info("Saving response for SO: {}, itemId: {}, response: {}",
                soNumber, request.getItemId(), request.getResponse());

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

        // Store response
        responseStore.computeIfAbsent(soNumber, k -> new HashMap<>())
                .put(request.getItemId(), response);

        logger.info("Response saved successfully");
        return convertToDTO(response);
    }

    /**
     * Delete response
     */
    public boolean deleteResponse(String soNumber, String itemId) {
        logger.info("Deleting response for SO: {}, itemId: {}", soNumber, itemId);

        Map<String, InspectionResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return false;
        }

        InspectionResponse removed = responses.remove(itemId);
        return removed != null;
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
