package com.pha.inspection.model.dto;

/**
 * DTO for Inspection Response API responses
 */
public class ResponseDTO {

    private String itemId;
    private String response;
    private String scopeOfWork;
    private Boolean materialRequired;
    private String materialDescription;
    private String serviceId;
    private String activityCode;
    private Boolean tenantCharge;
    private Boolean urgent;
    private Boolean rrp;
    private String createdAt;

    public ResponseDTO() {
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public String getScopeOfWork() {
        return scopeOfWork;
    }

    public void setScopeOfWork(String scopeOfWork) {
        this.scopeOfWork = scopeOfWork;
    }

    public Boolean getMaterialRequired() {
        return materialRequired;
    }

    public void setMaterialRequired(Boolean materialRequired) {
        this.materialRequired = materialRequired;
    }

    public String getMaterialDescription() {
        return materialDescription;
    }

    public void setMaterialDescription(String materialDescription) {
        this.materialDescription = materialDescription;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getActivityCode() {
        return activityCode;
    }

    public void setActivityCode(String activityCode) {
        this.activityCode = activityCode;
    }

    public Boolean getTenantCharge() {
        return tenantCharge;
    }

    public void setTenantCharge(Boolean tenantCharge) {
        this.tenantCharge = tenantCharge;
    }

    public Boolean getUrgent() {
        return urgent;
    }

    public void setUrgent(Boolean urgent) {
        this.urgent = urgent;
    }

    public Boolean getRrp() {
        return rrp;
    }

    public void setRrp(Boolean rrp) {
        this.rrp = rrp;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
