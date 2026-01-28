package com.pha.inspection.model.dto;

/**
 * DTO for creating a new inspection
 */
public class CreateInspectionRequest {

    private String unitNumber;
    private String siteCode;
    private String siteName;
    private String address;
    private String divisionCode;

    // Tenant info
    private String tenantName;
    private String tenantPhone;
    private Boolean tenantAvailability;

    // Unit info
    private Integer brSize;
    private Boolean isHardwired;

    // Inspector info
    private String inspectorId;
    private String inspectorName;
    private String vehicleTagId;

    // Schedule
    private String startDate;       // YYYY-MM-DD
    private String startTime;       // HH:mm:ss

    public CreateInspectionRequest() {
    }

    public String getUnitNumber() {
        return unitNumber;
    }

    public void setUnitNumber(String unitNumber) {
        this.unitNumber = unitNumber;
    }

    public String getSiteCode() {
        return siteCode;
    }

    public void setSiteCode(String siteCode) {
        this.siteCode = siteCode;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getDivisionCode() {
        return divisionCode;
    }

    public void setDivisionCode(String divisionCode) {
        this.divisionCode = divisionCode;
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

    public Integer getBrSize() {
        return brSize;
    }

    public void setBrSize(Integer brSize) {
        this.brSize = brSize;
    }

    public Boolean getIsHardwired() {
        return isHardwired;
    }

    public void setIsHardwired(Boolean isHardwired) {
        this.isHardwired = isHardwired;
    }

    public String getInspectorId() {
        return inspectorId;
    }

    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
    }

    public String getInspectorName() {
        return inspectorName;
    }

    public void setInspectorName(String inspectorName) {
        this.inspectorName = inspectorName;
    }

    public String getVehicleTagId() {
        return vehicleTagId;
    }

    public void setVehicleTagId(String vehicleTagId) {
        this.vehicleTagId = vehicleTagId;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }
}
