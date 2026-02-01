package com.pha.inspection.controller;

import com.pha.inspection.model.dto.CreateInspectorRequest;
import com.pha.inspection.model.dto.LoginRequest;
import com.pha.inspection.model.dto.LoginResponse;
import com.pha.inspection.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Authentication Controller
 * Handles login and authentication endpoints
 */
@RestController
@RequestMapping("/auth")
@Tag(name = "Authentication", description = "Authentication endpoints for inspectors")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private AuthService authService;

    /**
     * Login endpoint
     */
    @PostMapping("/login")
    @Operation(summary = "Inspector login", description = "Authenticate inspector and receive JWT token")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            LoginResponse response = authService.login(loginRequest);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Login failed for inspector: {}", loginRequest.getInspectorId(), e);

            Map<String, String> error = new HashMap<>();
            error.put("error", "Authentication failed");
            error.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * Create inspector endpoint (supports both JSON body and query parameters)
     * Used by iPad app signup and Swagger UI testing
     */
    @PostMapping("/create-inspector")
    @Operation(summary = "Create inspector account", description = "Create a new inspector account with JSON body or query parameters")
    public ResponseEntity<?> createInspector(
            @Valid @RequestBody(required = false) CreateInspectorRequest requestBody,
            @RequestParam(required = false) String inspectorId,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String password,
            @RequestParam(required = false) String vehicleTagId) {
        try {
            // Support both JSON body (from iPad app) and query parameters (from Swagger UI)
            String finalInspectorId = requestBody != null ? requestBody.getInspectorId() : inspectorId;
            String finalName = requestBody != null ? requestBody.getName() : name;
            String finalPassword = requestBody != null ? requestBody.getPassword() : password;
            String finalVehicleTagId = requestBody != null ? requestBody.getVehicleTagId() : vehicleTagId;

            // Validate required fields
            if (finalInspectorId == null || finalName == null || finalPassword == null || finalVehicleTagId == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Missing required fields");
                error.put("message", "inspectorId, name, password, and vehicleTagId are required");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
            }

            authService.createInspector(finalInspectorId, finalName, finalPassword, finalVehicleTagId);

            Map<String, String> response = new HashMap<>();
            response.put("message", "Inspector created successfully");
            response.put("inspectorId", finalInspectorId);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Failed to create inspector", e);

            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to create inspector");
            error.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }
}
