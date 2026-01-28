package com.pha.inspection.model.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO for login requests
 */
public class LoginRequest {

    @NotBlank(message = "Inspector ID is required")
    private String inspectorId;

    @NotBlank(message = "Password is required")
    private String password;

    public LoginRequest() {
    }

    public LoginRequest(String inspectorId, String password) {
        this.inspectorId = inspectorId;
        this.password = password;
    }

    public String getInspectorId() {
        return inspectorId;
    }

    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
