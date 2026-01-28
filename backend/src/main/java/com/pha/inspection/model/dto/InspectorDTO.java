package com.pha.inspection.model.dto;

/**
 * DTO for Inspector information (without password)
 */
public class InspectorDTO {

    private String inspectorId;
    private String name;
    private String vehicleTagId;
    private Boolean active;

    public InspectorDTO() {
    }

    public InspectorDTO(String inspectorId, String name, String vehicleTagId, Boolean active) {
        this.inspectorId = inspectorId;
        this.name = name;
        this.vehicleTagId = vehicleTagId;
        this.active = active;
    }

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

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
