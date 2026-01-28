package com.pha.inspection.controller;

import com.pha.inspection.model.dto.CreatePMIResponseRequest;
import com.pha.inspection.model.dto.PMICategoryDTO;
import com.pha.inspection.model.dto.PMIItemDTO;
import com.pha.inspection.model.dto.PMIResponseDTO;
import com.pha.inspection.service.PMIResponseService;
import com.pha.inspection.service.PMIService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * PMI Controller
 * Handles PMI (Preventive Maintenance Inspection) endpoints
 */
@RestController
@RequestMapping("/pmi")
@Tag(name = "PMI Checklist", description = "Preventive Maintenance Inspection management")
@SecurityRequirement(name = "Bearer Authentication")
public class PMIController {

    private static final Logger logger = LoggerFactory.getLogger(PMIController.class);

    @Autowired
    private PMIService pmiService;

    @Autowired
    private PMIResponseService pmiResponseService;

    /**
     * Get all PMI categories
     */
    @GetMapping("/categories")
    @Operation(
            summary = "Get all PMI categories",
            description = "List all PMI categories sorted by sortOrder"
    )
    public ResponseEntity<List<PMICategoryDTO>> getAllCategories() {
        logger.info("GET /pmi/categories");

        List<PMICategoryDTO> categories = pmiService.getAllCategories();
        return ResponseEntity.ok(categories);
    }

    /**
     * Get items for specific category
     */
    @GetMapping("/categories/{categoryId}/items")
    @Operation(
            summary = "Get PMI items by category",
            description = "List all PMI items for a specific category sorted by sortOrder"
    )
    public ResponseEntity<List<PMIItemDTO>> getItemsByCategory(@PathVariable String categoryId) {
        logger.info("GET /pmi/categories/{}/items", categoryId);

        List<PMIItemDTO> items = pmiService.getItemsByCategory(categoryId);
        return ResponseEntity.ok(items);
    }

    /**
     * Get all PMI responses for an inspection
     */
    @GetMapping("/inspections/{soNumber}/responses")
    @Operation(
            summary = "Get all PMI responses for inspection",
            description = "List all PMI item responses for a specific inspection"
    )
    public ResponseEntity<List<PMIResponseDTO>> getPMIResponses(@PathVariable String soNumber) {
        logger.info("GET /pmi/inspections/{}/responses", soNumber);

        List<PMIResponseDTO> responses = pmiResponseService.getResponsesBySoNumber(soNumber);
        return ResponseEntity.ok(responses);
    }

    /**
     * Get single PMI response
     */
    @GetMapping("/inspections/{soNumber}/responses/{itemId}")
    @Operation(
            summary = "Get PMI response by item ID",
            description = "Get a specific PMI item response"
    )
    public ResponseEntity<?> getPMIResponse(@PathVariable String soNumber, @PathVariable String itemId) {
        logger.info("GET /pmi/inspections/{}/responses/{}", soNumber, itemId);

        Optional<PMIResponseDTO> response = pmiResponseService.getResponse(soNumber, itemId);

        if (response.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "PMI response not found");
            error.put("soNumber", soNumber);
            error.put("itemId", itemId);
            return ResponseEntity.status(404).body(error);
        }

        return ResponseEntity.ok(response.get());
    }

    /**
     * Create or update PMI response
     */
    @PostMapping("/inspections/{soNumber}/responses")
    @Operation(
            summary = "Create or update PMI response",
            description = "Save PMI item response (completed true/false with optional notes)"
    )
    public ResponseEntity<?> savePMIResponse(
            @PathVariable String soNumber,
            @RequestBody CreatePMIResponseRequest request) {

        logger.info("POST /pmi/inspections/{}/responses", soNumber);

        try {
            PMIResponseDTO response = pmiResponseService.saveResponse(soNumber, request);
            return ResponseEntity.status(201).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(400).body(error);
        }
    }

    /**
     * Delete PMI response
     */
    @DeleteMapping("/inspections/{soNumber}/responses/{itemId}")
    @Operation(
            summary = "Delete PMI response",
            description = "Delete a PMI item response"
    )
    public ResponseEntity<Map<String, String>> deletePMIResponse(
            @PathVariable String soNumber,
            @PathVariable String itemId) {

        logger.info("DELETE /pmi/inspections/{}/responses/{}", soNumber, itemId);

        boolean deleted = pmiResponseService.deleteResponse(soNumber, itemId);

        if (!deleted) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "PMI response not found");
            error.put("soNumber", soNumber);
            error.put("itemId", itemId);
            return ResponseEntity.status(404).body(error);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "PMI response deleted successfully");
        response.put("soNumber", soNumber);
        response.put("itemId", itemId);

        return ResponseEntity.ok(response);
    }
}
