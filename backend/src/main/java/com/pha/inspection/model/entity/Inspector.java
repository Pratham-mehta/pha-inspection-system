package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSecondaryPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSecondarySortKey;

import java.time.Instant;

/**
 * Inspector entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTOR#{inspectorId}
 * SK: METADATA
 * GSI1PK: INSPECTORS
 * GSI1SK: INSPECTOR#{inspectorId}
 */
@DynamoDbBean
public class Inspector {

    private String PK;              // INSPECTOR#{inspectorId}
    private String SK;              // METADATA
    private String entityType;      // "Inspector"
    private String inspectorId;     // INS001, INS002, etc.
    private String name;            // CASTOR_USER5
    private String vehicleTagId;    // Q, R, S
    private Boolean active;         // true/false
    private String password;        // BCrypt hashed password
    private String createdAt;       // ISO 8601 timestamp

    // GSI1 attributes for querying all inspectors
    private String GSI1PK;          // INSPECTORS
    private String GSI1SK;          // INSPECTOR#{inspectorId}

    public Inspector() {
        this.entityType = "Inspector";
        this.SK = "METADATA";
        this.active = true;
        this.createdAt = Instant.now().toString();
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

    // Entity Type
    @DynamoDbAttribute("EntityType")
    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    // Inspector ID
    @DynamoDbAttribute("inspectorId")
    public String getInspectorId() {
        return inspectorId;
    }

    public void setInspectorId(String inspectorId) {
        this.inspectorId = inspectorId;
        // Automatically set PK when inspectorId is set
        if (inspectorId != null) {
            this.PK = "INSPECTOR#" + inspectorId;
            this.GSI1SK = "INSPECTOR#" + inspectorId;
        }
    }

    // Name
    @DynamoDbAttribute("name")
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Vehicle Tag ID
    @DynamoDbAttribute("vehicleTagId")
    public String getVehicleTagId() {
        return vehicleTagId;
    }

    public void setVehicleTagId(String vehicleTagId) {
        this.vehicleTagId = vehicleTagId;
    }

    // Active
    @DynamoDbAttribute("active")
    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    // Password (hashed)
    @DynamoDbAttribute("password")
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    // Created At
    @DynamoDbAttribute("createdAt")
    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    // GSI1 Partition Key
    @DynamoDbSecondaryPartitionKey(indexNames = "GSI1")
    @DynamoDbAttribute("GSI1PK")
    public String getGSI1PK() {
        return GSI1PK;
    }

    public void setGSI1PK(String GSI1PK) {
        this.GSI1PK = GSI1PK;
    }

    // GSI1 Sort Key
    @DynamoDbSecondarySortKey(indexNames = "GSI1")
    @DynamoDbAttribute("GSI1SK")
    public String getGSI1SK() {
        return GSI1SK;
    }

    public void setGSI1SK(String GSI1SK) {
        this.GSI1SK = GSI1SK;
    }

    // Helper method to initialize GSI attributes
    public void initializeGSI() {
        this.GSI1PK = "INSPECTORS";
        if (this.inspectorId != null) {
            this.GSI1SK = "INSPECTOR#" + this.inspectorId;
        }
    }
}
