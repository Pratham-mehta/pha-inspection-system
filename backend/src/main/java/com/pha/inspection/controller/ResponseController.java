package com.pha.inspection.controller;

import com.pha.inspection.model.dto.CreateResponseRequest;
import com.pha.inspection.model.dto.ResponseDTO;
import com.pha.inspection.service.ResponseService;
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
 * Response Controller
 * Handles inspection response endpoints
 */
@RestController
@RequestMapping("/inspections")
@Tag(name = "Inspection Responses", description = "Inspection item response management")
@SecurityRequirement(name = "Bearer Authentication")
public class ResponseController {

    private static final Logger logger = LoggerFactory.getLogger(ResponseController.class);

    @Autowired
    private ResponseService responseService;

    /**
     * Get all responses for an inspection
     */
    @GetMapping("/{soNumber}/responses")
    @Operation(
            summary = "Get all responses for inspection",
            description = "List all item responses for a specific inspection"
    )
    public ResponseEntity<List<ResponseDTO>> getResponses(@PathVariable String soNumber) {
        logger.info("GET /inspections/{}/responses", soNumber);

        List<ResponseDTO> responses = responseService.getResponsesBySoNumber(soNumber);
        return ResponseEntity.ok(responses);
    }

    /**
     * Get single response
     */
    @GetMapping("/{soNumber}/responses/{itemId}")
    @Operation(
            summary = "Get response by item ID",
            description = "Get a specific item response"
    )
    public ResponseEntity<?> getResponse(@PathVariable String soNumber, @PathVariable String itemId) {
        logger.info("GET /inspections/{}/responses/{}", soNumber, itemId);

        Optional<ResponseDTO> response = responseService.getResponse(soNumber, itemId);

        if (response.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Response not found");
            error.put("soNumber", soNumber);
            error.put("itemId", itemId);
            return ResponseEntity.status(404).body(error);
        }

        return ResponseEntity.ok(response.get());
    }

    /**
     * Create or update response
     */
    @PostMapping("/{soNumber}/responses")
    @Operation(
            summary = "Create or update response",
            description = "Save inspection item response (OK, NA, or Def with deficiency details)"
    )
    public ResponseEntity<?> saveResponse(
            @PathVariable String soNumber,
            @RequestBody CreateResponseRequest request) {

        logger.info("POST /inspections/{}/responses", soNumber);

        try {
            ResponseDTO response = responseService.saveResponse(soNumber, request);
            return ResponseEntity.status(201).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(400).body(error);
        }
    }

    /**
     * Delete response
     */
    @DeleteMapping("/{soNumber}/responses/{itemId}")
    @Operation(
            summary = "Delete response",
            description = "Delete an inspection item response"
    )
    public ResponseEntity<Map<String, String>> deleteResponse(
            @PathVariable String soNumber,
            @PathVariable String itemId) {

        logger.info("DELETE /inspections/{}/responses/{}", soNumber, itemId);

        boolean deleted = responseService.deleteResponse(soNumber, itemId);

        if (!deleted) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Response not found");
            error.put("soNumber", soNumber);
            error.put("itemId", itemId);
            return ResponseEntity.status(404).body(error);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "Response deleted successfully");
        response.put("soNumber", soNumber);
        response.put("itemId", itemId);

        return ResponseEntity.ok(response);
    }
}
