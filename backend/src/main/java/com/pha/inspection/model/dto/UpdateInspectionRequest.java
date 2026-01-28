package com.pha.inspection.model.dto;

/**
 * DTO for updating an inspection
 * All fields are optional - only provided fields will be updated
 */
public class UpdateInspectionRequest {

    private String status;          // New, InProgress, Closed
    private String startTime;
    private String endDate;
    private String endTime;
    private String submitTime;
    private String completionDate;

    // Tenant info updates
    private String tenantName;
    private String tenantPhone;
    private Boolean tenantAvailability;

    // Detector counts
    private Integer smokeDetectorsCount;
    private Integer coDetectorsCount;

    public UpdateInspectionRequest() {
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getSubmitTime() {
        return submitTime;
    }

    public void setSubmitTime(String submitTime) {
        this.submitTime = submitTime;
    }

    public String getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(String completionDate) {
        this.completionDate = completionDate;
    }

    public String getTenantName() {
        return tenantName;
    }

    public void setTenantName(String tenantName) {
        this.tenantName = tenantName;
    }

    public String getTenantPhone() {
        return tenantPhone;
    }

    public void setTenantPhone(String tenantPhone) {
        this.tenantPhone = tenantPhone;
    }

    public Boolean getTenantAvailability() {
        return tenantAvailability;
    }

    public void setTenantAvailability(Boolean tenantAvailability) {
        this.tenantAvailability = tenantAvailability;
    }

    public Integer getSmokeDetectorsCount() {
        return smokeDetectorsCount;
    }

    public void setSmokeDetectorsCount(Integer smokeDetectorsCount) {
        this.smokeDetectorsCount = smokeDetectorsCount;
    }

    public Integer getCoDetectorsCount() {
        return coDetectorsCount;
    }

    public void setCoDetectorsCount(Integer coDetectorsCount) {
        this.coDetectorsCount = coDetectorsCount;
    }
}
