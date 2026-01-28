package com.pha.inspection.controller;

import com.pha.inspection.model.dto.*;
import com.pha.inspection.service.InspectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Inspection Controller
 * Handles all inspection-related endpoints
 */
@RestController
@RequestMapping("/inspections")
@Tag(name = "Inspections", description = "Inspection management endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class InspectionController {

    private static final Logger logger = LoggerFactory.getLogger(InspectionController.class);

    @Autowired
    private InspectionService inspectionService;

    /**
     * Get all inspections with optional filters and pagination
     */
    @GetMapping
    @Operation(
            summary = "Get all inspections",
            description = "List all inspections with optional filters (status, area, siteCode) and pagination"
    )
    public ResponseEntity<InspectionListDTO> getAllInspections(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) String siteCode,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        logger.info("GET /inspections - status: {}, area: {}, siteCode: {}, page: {}, size: {}",
                status, area, siteCode, page, size);

        InspectionListDTO result = inspectionService.getAllInspections(status, area, siteCode, page, size);
        return ResponseEntity.ok(result);
    }

    /**
     * Get inspection by SO number
     */
    @GetMapping("/{soNumber}")
    @Operation(
            summary = "Get inspection by SO number",
            description = "Get detailed inspection information by Service Order number"
    )
    public ResponseEntity<?> getInspectionBySoNumber(@PathVariable String soNumber) {
        logger.info("GET /inspections/{}", soNumber);

        Optional<InspectionDTO> inspection = inspectionService.getInspectionBySoNumber(soNumber);

        if (inspection.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Inspection not found");
            error.put("soNumber", soNumber);
            return ResponseEntity.status(404).body(error);
        }

        return ResponseEntity.ok(inspection.get());
    }

    /**
     * Create new inspection
     */
    @PostMapping
    @Operation(
            summary = "Create new inspection",
            description = "Create a new inspection order"
    )
    public ResponseEntity<Map<String, String>> createInspection(@RequestBody CreateInspectionRequest request) {
        logger.info("POST /inspections - unitNumber: {}", request.getUnitNumber());

        String soNumber = inspectionService.createInspection(request);

        Map<String, String> response = new HashMap<>();
        response.put("soNumber", soNumber);
        response.put("message", "Inspection created successfully");

        return ResponseEntity.status(201).body(response);
    }

    /**
     * Update inspection
     */
    @PutMapping("/{soNumber}")
    @Operation(
            summary = "Update inspection",
            description = "Update an existing inspection (partial update supported)"
    )
    public ResponseEntity<Map<String, String>> updateInspection(
            @PathVariable String soNumber,
            @RequestBody UpdateInspectionRequest request) {

        logger.info("PUT /inspections/{}", soNumber);

        boolean updated = inspectionService.updateInspection(soNumber, request);

        if (!updated) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Inspection not found");
            error.put("soNumber", soNumber);
            return ResponseEntity.status(404).body(error);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "Inspection updated successfully");
        response.put("soNumber", soNumber);

        return ResponseEntity.ok(response);
    }

    /**
     * Submit inspection (close it)
     */
    @PostMapping("/{soNumber}/submit")
    @Operation(
            summary = "Submit inspection",
            description = "Submit and close an inspection"
    )
    public ResponseEntity<Map<String, String>> submitInspection(
            @PathVariable String soNumber,
            @RequestBody UpdateInspectionRequest request) {

        logger.info("POST /inspections/{}/submit", soNumber);

        boolean submitted = inspectionService.submitInspection(soNumber, request);

        if (!submitted) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Inspection not found");
            error.put("soNumber", soNumber);
            return ResponseEntity.status(404).body(error);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "Inspection submitted successfully");
        response.put("status", "Closed");
        response.put("soNumber", soNumber);

        return ResponseEntity.ok(response);
    }
}
