package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSecondaryPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSecondarySortKey;

import java.time.Instant;

/**
 * Inspection entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION#{soNumber}
 * SK: METADATA
 * GSI1PK: UNIT#{unitNumber}
 * GSI1SK: INSPECTION#{soNumber}
 * GSI2PK: STATUS#{status}
 * GSI2SK: DATE#{startDate}
 * GSI3PK: INSPECTOR#{inspectorId}
 * GSI3SK: DATE#{startDate}
 */
@DynamoDbBean
public class Inspection {

    private String PK;              // INSPECTION#{soNumber}
    private String SK;              // METADATA
    private String entityType;      // "Inspection"

    // Inspection fields
    private String soNumber;        // Service Order Number (unique ID)
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
    private Integer brSize;         // Bedroom size
    private Boolean isHardwired;

    // Inspector info
    private String inspectorId;
    private String inspectorName;
    private String vehicleTagId;

    // Status and dates
    private String status;          // New, InProgress, Closed
    private String startDate;       // YYYY-MM-DD
    private String startTime;       // HH:mm:ss
    private String endDate;         // YYYY-MM-DD
    private String endTime;         // HH:mm:ss
    private String submitTime;      // ISO 8601 timestamp
    private String completionDate;  // YYYY-MM-DD

    // Detector counts
    private Integer smokeDetectorsCount;
    private Integer coDetectorsCount;

    // Timestamps
    private String createdAt;       // ISO 8601 timestamp
    private String updatedAt;       // ISO 8601 timestamp

    // GSI attributes
    private String GSI1PK;          // UNIT#{unitNumber}
    private String GSI1SK;          // INSPECTION#{soNumber}
    private String GSI2PK;          // STATUS#{status}
    private String GSI2SK;          // DATE#{startDate}
    private String GSI3PK;          // INSPECTOR#{inspectorId}
    private String GSI3SK;          // DATE#{startDate}

    public Inspection() {
        this.entityType = "Inspection";
        this.SK = "METADATA";
        this.status = "New";
        this.tenantAvailability = true;
        this.isHardwired = false;
        this.createdAt = Instant.now().toString();
        this.updatedAt = Instant.now().toString();
    }

    // Partition Key
    @DynamoDbPartitionKey
    @DynamoDbAttribute("PK")
    public String getPK() {
        return PK;
    }

    public void setPK(String PK) {
        this.PK = PK;
    }

    // Sort Key
    @DynamoDbSortKey
    @DynamoDbAttribute("SK")
    public String getSK() {
        return SK;
    }

    public void setSK(String SK) {
        this.SK = SK;
    }

    @DynamoDbAttribute("EntityType")
    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    @DynamoDbAttribute("soNumber")
    public String getSoNumber() {
        return soNumber;
    }

    public void setSoNumber(String soNumber) {
        this.soNumber = soNumber;
        if (soNumber != null) {
            this.PK = "INSPECTION#" + soNumber;
            this.GSI1SK = "INSPECTION#" + soNumber;
        }
    }

    @DynamoDbAttribute("unitNumber")
    public String getUnitNumber() {
        return unitNumber;
    }

    public void setUnitNumber(String unitNumber) {
        this.unitNumber = unitNumber;
        if (unitNumber != null) {
            this.GSI1PK = "UNIT#" + unitNumber;
        }
    }

    @DynamoDbAttribute("siteCode")
    public String getSiteCode() {
        return siteCode;
    }

    public void setSiteCode(String siteCode) {
        this.siteCode = siteCode;
    }

    @DynamoDbAttribute("siteName")
    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    @DynamoDbAttribute("address")
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @DynamoDbAttribute("divisionCode")
    public String getDivisionCode() {
        return divisionCode;
    }

    public void setDivisionCode(String divisionCode) {
        this.divisionCode = divisionCode;
    }

    @DynamoDbAttribute("tenantName")
    public String getTenantName() {
        return tenantName;
    }

    public void setTenantName(String tenantName) {
        this.tenantName = tenantName;
    }

    @DynamoDbAttribute("tenantPhone")
    public String getTenantPhone() {
        return tenantPhone;
    }

    public void setTenantPhone(String tenantPhone) {
        this.tenantPhone = tenantPhone;
    }

    @DynamoDbAttribute("tenantAvailability")
    public Boolean getTenantAvailability() {
        return tenantAvailability;
    }

    public void setTenantAvailability(Boolean tenantAvailability) {
        this.tenantAvailability = tenantAvailability;
    }

    @DynamoDbAttribute("brSize")
    public Integer getBrSize() {
        return brSize;
    }

    public void setBrSize(Integer brSize) {
        this.brSize = brSize;
    }

    @DynamoDbAttribute("isHardwired")
    public Boolean getIsHardwired() {
        return isHardwired;
    }

    public void setIsHardwired(Boolean isHardwired) {
        this.isHardwired = isHardwired;
    }

    @DynamoDbAttribute("inspectorId")
    public String getInspectorId() {
        return inspectorId;
    }

    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
        if (inspectorId != null) {
            this.GSI3PK = "INSPECTOR#" + inspectorId;
        }
    }

    @DynamoDbAttribute("inspectorName")
    public String getInspectorName() {
        return inspectorName;
    }

    public void setInspectorName(String inspectorName) {
        this.inspectorName = inspectorName;
    }

    @DynamoDbAttribute("vehicleTagId")
    public String getVehicleTagId() {
        return vehicleTagId;
    }

    public void setVehicleTagId(String vehicleTagId) {
        this.vehicleTagId = vehicleTagId;
    }

    @DynamoDbAttribute("status")
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        if (status != null) {
            this.GSI2PK = "STATUS#" + status;
        }
        this.updatedAt = Instant.now().toString();
    }

    @DynamoDbAttribute("startDate")
    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
        if (startDate != null) {
            this.GSI2SK = "DATE#" + startDate;
            this.GSI3SK = "DATE#" + startDate;
        }
    }

    @DynamoDbAttribute("startTime")
    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    @DynamoDbAttribute("endDate")
    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    @DynamoDbAttribute("endTime")
    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    @DynamoDbAttribute("submitTime")
    public String getSubmitTime() {
        return submitTime;
    }

    public void setSubmitTime(String submitTime) {
        this.submitTime = submitTime;
    }

    @DynamoDbAttribute("completionDate")
    public String getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(String completionDate) {
        this.completionDate = completionDate;
    }

    @DynamoDbAttribute("smokeDetectorsCount")
    public Integer getSmokeDetectorsCount() {
        return smokeDetectorsCount;
    }

    public void setSmokeDetectorsCount(Integer smokeDetectorsCount) {
        this.smokeDetectorsCount = smokeDetectorsCount;
    }

    @DynamoDbAttribute("coDetectorsCount")
    public Integer getCoDetectorsCount() {
        return coDetectorsCount;
    }

    public void setCoDetectorsCount(Integer coDetectorsCount) {
        this.coDetectorsCount = coDetectorsCount;
    }

    @DynamoDbAttribute("createdAt")
    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    @DynamoDbAttribute("updatedAt")
    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    // GSI1 - Unit lookups
    @DynamoDbSecondaryPartitionKey(indexNames = "GSI1")
    @DynamoDbAttribute("GSI1PK")
    public String getGSI1PK() {
        return GSI1PK;
    }

    public void setGSI1PK(String GSI1PK) {
        this.GSI1PK = GSI1PK;
    }

    @DynamoDbSecondarySortKey(indexNames = "GSI1")
    @DynamoDbAttribute("GSI1SK")
    public String getGSI1SK() {
        return GSI1SK;
    }

    public void setGSI1SK(String GSI1SK) {
        this.GSI1SK = GSI1SK;
    }

    // GSI2 - Status lookups
    @DynamoDbSecondaryPartitionKey(indexNames = "GSI2")
    @DynamoDbAttribute("GSI2PK")
    public String getGSI2PK() {
        return GSI2PK;
    }

    public void setGSI2PK(String GSI2PK) {
        this.GSI2PK = GSI2PK;
    }

    @DynamoDbSecondarySortKey(indexNames = "GSI2")
    @DynamoDbAttribute("GSI2SK")
    public String getGSI2SK() {
        return GSI2SK;
    }

    public void setGSI2SK(String GSI2SK) {
        this.GSI2SK = GSI2SK;
    }

    // GSI3 - Inspector lookups
    @DynamoDbSecondaryPartitionKey(indexNames = "GSI3")
    @DynamoDbAttribute("GSI3PK")
    public String getGSI3PK() {
        return GSI3PK;
    }

    public void setGSI3PK(String GSI3PK) {
        this.GSI3PK = GSI3PK;
    }

    @DynamoDbSecondarySortKey(indexNames = "GSI3")
    @DynamoDbAttribute("GSI3SK")
    public String getGSI3SK() {
        return GSI3SK;
    }

    public void setGSI3SK(String GSI3SK) {
        this.GSI3SK = GSI3SK;
    }

    public void initializeGSI() {
        if (this.unitNumber != null) {
            this.GSI1PK = "UNIT#" + this.unitNumber;
        }
        if (this.soNumber != null) {
            this.GSI1SK = "INSPECTION#" + this.soNumber;
        }
        if (this.status != null) {
            this.GSI2PK = "STATUS#" + this.status;
        }
        if (this.startDate != null) {
            this.GSI2SK = "DATE#" + this.startDate;
            this.GSI3SK = "DATE#" + this.startDate;
        }
        if (this.inspectorId != null) {
            this.GSI3PK = "INSPECTOR#" + this.inspectorId;
        }
    }
}
