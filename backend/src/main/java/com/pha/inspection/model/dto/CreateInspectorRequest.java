package com.pha.inspection.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Request DTO for creating a new inspector
 */
public class CreateInspectorRequest {

    @NotBlank(message = "Inspector ID is required")
    private String inspectorId;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Vehicle Tag ID is required")
    private String vehicleTagId;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    // Constructors
    public CreateInspectorRequest() {}

    public CreateInspectorRequest(String inspectorId, String name, String vehicleTagId, String password) {
        this.inspectorId = inspectorId;
        this.name = name;
        this.vehicleTagId = vehicleTagId;
        this.password = password;
    }

    // Getters and Setters
    public String getInspectorId() {
        return inspectorId;
    }

    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getVehicleTagId() {
        return vehicleTagId;
    }

    public void setVehicleTagId(String vehicleTagId) {
        this.vehicleTagId = vehicleTagId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
