package com.pha.inspection.model.dto;

/**
 * DTO for inspection summary in list views
 * Contains minimal fields for table/list display
 */
public class InspectionSummaryDTO {

    private String soNumber;
    private String unitNumber;
    private String soDate;           // Start date (renamed for clarity)
    private String divisionCode;
    private String siteCode;
    private String siteName;
    private String tenantName;
    private String address;
    private String completionDate;
    private String status;

    public InspectionSummaryDTO() {
    }

    public InspectionSummaryDTO(String soNumber, String unitNumber, String soDate, String divisionCode,
                                String siteCode, String siteName, String tenantName, String address,
                                String completionDate, String status) {
        this.soNumber = soNumber;
        this.unitNumber = unitNumber;
        this.soDate = soDate;
        this.divisionCode = divisionCode;
        this.siteCode = siteCode;
        this.siteName = siteName;
        this.tenantName = tenantName;
        this.address = address;
        this.completionDate = completionDate;
        this.status = status;
    }

    public String getSoNumber() {
        return soNumber;
    }

    public void setSoNumber(String soNumber) {
        this.soNumber = soNumber;
    }

    public String getUnitNumber() {
        return unitNumber;
    }

    public void setUnitNumber(String unitNumber) {
        this.unitNumber = unitNumber;
    }

    public String getSoDate() {
        return soDate;
    }

    public void setSoDate(String soDate) {
        this.soDate = soDate;
    }

    public String getDivisionCode() {
        return divisionCode;
    }

    public void setDivisionCode(String divisionCode) {
        this.divisionCode = divisionCode;
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

    public String getTenantName() {
        return tenantName;
    }

    public void setTenantName(String tenantName) {
        this.tenantName = tenantName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(String completionDate) {
        this.completionDate = completionDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
