package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * Inspection Response entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION#{soNumber}
 * SK: RESPONSE#{itemId}
 */
@DynamoDbBean
public class InspectionResponse {

    private String PK;              // INSPECTION#{soNumber}
    private String SK;              // RESPONSE#{itemId}
    private String entityType;      // "InspectionResponse"

    private String soNumber;        // Parent inspection SO number
    private String itemId;          // Inspection item ID (e.g., "K001", "B001")
    private String response;        // "OK", "NA", or "Def"

    // Deficiency fields (only if response = "Def")
    private String scopeOfWork;
    private Boolean materialRequired;
    private String materialDescription;
    private String serviceId;       // Service code (e.g., "100-PLUMBING")
    private String activityCode;    // Activity code (e.g., "703")
    private Boolean tenantCharge;
    private Boolean urgent;
    private Boolean rrp;            // Lead-safe work practices required

    private String createdAt;

    public InspectionResponse() {
        this.entityType = "InspectionResponse";
        this.tenantCharge = false;
        this.urgent = false;
        this.rrp = false;
        this.materialRequired = false;
    }

    public InspectionResponse(String soNumber, String itemId, String response) {
        this();
        this.soNumber = soNumber;
        this.itemId = itemId;
        this.response = response;
        this.PK = "INSPECTION#" + soNumber;
        this.SK = "RESPONSE#" + itemId;
    }

    @DynamoDbPartitionKey
    @DynamoDbAttribute("PK")
    public String getPK() {
        return PK;
    }

    public void setPK(String PK) {
        this.PK = PK;
    }

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
        }
    }

    @DynamoDbAttribute("itemId")
    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
        if (itemId != null) {
            this.SK = "RESPONSE#" + itemId;
        }
    }

    @DynamoDbAttribute("response")
    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    @DynamoDbAttribute("scopeOfWork")
    public String getScopeOfWork() {
        return scopeOfWork;
    }

    public void setScopeOfWork(String scopeOfWork) {
        this.scopeOfWork = scopeOfWork;
    }

    @DynamoDbAttribute("materialRequired")
    public Boolean getMaterialRequired() {
        return materialRequired;
    }

    public void setMaterialRequired(Boolean materialRequired) {
        this.materialRequired = materialRequired;
    }

    @DynamoDbAttribute("materialDescription")
    public String getMaterialDescription() {
        return materialDescription;
    }

    public void setMaterialDescription(String materialDescription) {
        this.materialDescription = materialDescription;
    }

    @DynamoDbAttribute("serviceId")
    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    @DynamoDbAttribute("activityCode")
    public String getActivityCode() {
        return activityCode;
    }

    public void setActivityCode(String activityCode) {
        this.activityCode = activityCode;
    }

    @DynamoDbAttribute("tenantCharge")
    public Boolean getTenantCharge() {
        return tenantCharge;
    }

    public void setTenantCharge(Boolean tenantCharge) {
        this.tenantCharge = tenantCharge;
    }

    @DynamoDbAttribute("urgent")
    public Boolean getUrgent() {
        return urgent;
    }

    public void setUrgent(Boolean urgent) {
        this.urgent = urgent;
    }

    @DynamoDbAttribute("rrp")
    public Boolean getRrp() {
        return rrp;
    }

    public void setRrp(Boolean rrp) {
        this.rrp = rrp;
    }

    @DynamoDbAttribute("createdAt")
    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
