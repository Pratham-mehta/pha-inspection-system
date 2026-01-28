package com.pha.inspection.service;

import com.pha.inspection.model.dto.InspectorDTO;
import com.pha.inspection.model.dto.LoginRequest;
import com.pha.inspection.model.dto.LoginResponse;
import com.pha.inspection.model.entity.Inspector;
import com.pha.inspection.repository.InspectorRepository;
import com.pha.inspection.security.JwtTokenProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Authentication Service
 * Handles login and authentication logic
 */
@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired(required = false)
    private InspectorRepository inspectorRepository;

    @Autowired
    private JwtTokenProvider tokenProvider;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // In-memory storage for Phase 2 testing (will be replaced with DynamoDB in Phase 3)
    private final java.util.Map<String, Inspector> inMemoryInspectors = new java.util.HashMap<>();

    /**
     * Authenticate inspector and generate JWT token
     */
    public LoginResponse login(LoginRequest loginRequest) {
        Inspector inspector = null;

        // Try in-memory first (for Phase 2 testing)
        inspector = inMemoryInspectors.get(loginRequest.getInspectorId());

        // If not found in memory and DynamoDB is available, try DynamoDB
        if (inspector == null && inspectorRepository != null) {
            Optional<Inspector> inspectorOpt = inspectorRepository.findByInspectorId(loginRequest.getInspectorId());
            inspector = inspectorOpt.orElse(null);
        }

        if (inspector == null) {
            throw new RuntimeException("Inspector not found: " + loginRequest.getInspectorId());
        }

        // Check if inspector is active
        if (!inspector.getActive()) {
            throw new RuntimeException("Inspector account is inactive");
        }

        // Verify password
        if (!passwordEncoder.matches(loginRequest.getPassword(), inspector.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        // Generate JWT token
        String token = tokenProvider.generateToken(inspector.getInspectorId());

        // Create inspector DTO (without password)
        InspectorDTO inspectorDTO = new InspectorDTO(
                inspector.getInspectorId(),
                inspector.getName(),
                inspector.getVehicleTagId(),
                inspector.getActive()
        );

        // Create login response
        LoginResponse response = new LoginResponse(
                token,
                tokenProvider.getExpirationMs(),
                inspectorDTO
        );

        logger.info("Inspector logged in successfully: {}", inspector.getInspectorId());

        return response;
    }

    /**
     * Create a new inspector (for testing purposes)
     * This would normally be done through an admin interface
     */
    public Inspector createInspector(String inspectorId, String name, String password, String vehicleTagId) {
        Inspector inspector = new Inspector();
        inspector.setInspectorId(inspectorId);
        inspector.setName(name);
        inspector.setPassword(passwordEncoder.encode(password));
        inspector.setVehicleTagId(vehicleTagId);
        inspector.setActive(true);

        // Store in memory for Phase 2
        inMemoryInspectors.put(inspectorId, inspector);

        // Also save to DynamoDB if available
        if (inspectorRepository != null) {
            try {
                return inspectorRepository.save(inspector);
            } catch (Exception e) {
                logger.warn("Could not save to DynamoDB, using in-memory storage only: {}", e.getMessage());
            }
        }

        return inspector;
    }
}
