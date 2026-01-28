package com.pha.inspection.service;

import com.pha.inspection.model.dto.CreatePMIResponseRequest;
import com.pha.inspection.model.dto.PMIResponseDTO;
import com.pha.inspection.model.entity.PMIResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * PMI Response Service
 * Handles PMI response CRUD operations
 */
@Service
public class PMIResponseService {

    private static final Logger logger = LoggerFactory.getLogger(PMIResponseService.class);

    // In-memory storage: Map<soNumber, Map<itemId, PMIResponse>>
    private final Map<String, Map<String, PMIResponse>> responseStore = new HashMap<>();

    /**
     * Get all PMI responses for an inspection
     */
    public List<PMIResponseDTO> getResponsesBySoNumber(String soNumber) {
        logger.info("Getting PMI responses for SO: {}", soNumber);

        Map<String, PMIResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return new ArrayList<>();
        }

        return responses.values().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get single PMI response by SO number and item ID
     */
    public Optional<PMIResponseDTO> getResponse(String soNumber, String itemId) {
        logger.info("Getting PMI response for SO: {}, itemId: {}", soNumber, itemId);

        Map<String, PMIResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return Optional.empty();
        }

        PMIResponse response = responses.get(itemId);
        return Optional.ofNullable(response).map(this::convertToDTO);
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

        // Create or update response
        PMIResponse response = new PMIResponse(soNumber, request.getItemId(), request.getCategoryId());
        response.setCompleted(request.getCompleted() != null ? request.getCompleted() : false);
        response.setNotes(request.getNotes());
        response.setCreatedAt(Instant.now().toString());

        // Store response
        responseStore.computeIfAbsent(soNumber, k -> new HashMap<>())
                .put(request.getItemId(), response);

        logger.info("PMI response saved successfully");
        return convertToDTO(response);
    }

    /**
     * Delete PMI response
     */
    public boolean deleteResponse(String soNumber, String itemId) {
        logger.info("Deleting PMI response for SO: {}, itemId: {}", soNumber, itemId);

        Map<String, PMIResponse> responses = responseStore.get(soNumber);
        if (responses == null) {
            return false;
        }

        PMIResponse removed = responses.remove(itemId);
        return removed != null;
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
