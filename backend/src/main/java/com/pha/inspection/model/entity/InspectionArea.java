package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * Inspection Area entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION_AREA#{areaName}
 * SK: METADATA
 */
@DynamoDbBean
public class InspectionArea {

    private String PK;              // INSPECTION_AREA#{areaName}
    private String SK;              // METADATA
    private String entityType;      // "InspectionArea"

    private String areaName;        // e.g., "Kitchen", "Bathroom", "Living Room"
    private Integer sortOrder;      // Display order
    private Boolean isActive;       // Active flag

    public InspectionArea() {
        this.entityType = "InspectionArea";
        this.SK = "METADATA";
        this.isActive = true;
    }

    public InspectionArea(String areaName, Integer sortOrder) {
        this();
        this.areaName = areaName;
        this.sortOrder = sortOrder;
        this.PK = "INSPECTION_AREA#" + areaName;
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

    @DynamoDbAttribute("areaName")
    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
        if (areaName != null) {
            this.PK = "INSPECTION_AREA#" + areaName;
        }
    }

    @DynamoDbAttribute("sortOrder")
    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }

    @DynamoDbAttribute("isActive")
    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
