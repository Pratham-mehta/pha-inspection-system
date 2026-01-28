package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * Inspection Item entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION_AREA#{areaName}
 * SK: ITEM#{itemId}
 */
@DynamoDbBean
public class InspectionItem {

    private String PK;              // INSPECTION_AREA#{areaName}
    private String SK;              // ITEM#{itemId}
    private String entityType;      // "InspectionItem"

    private String itemId;          // Unique item ID (e.g., "K001", "B001")
    private String areaName;        // Parent area name
    private String description;     // Item description
    private Integer sortOrder;      // Display order within area
    private Boolean isActive;       // Active flag

    public InspectionItem() {
        this.entityType = "InspectionItem";
        this.isActive = true;
    }

    public InspectionItem(String areaName, String itemId, String description, Integer sortOrder) {
        this();
        this.areaName = areaName;
        this.itemId = itemId;
        this.description = description;
        this.sortOrder = sortOrder;
        this.PK = "INSPECTION_AREA#" + areaName;
        this.SK = "ITEM#" + itemId;
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

    @DynamoDbAttribute("itemId")
    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
        if (itemId != null) {
            this.SK = "ITEM#" + itemId;
        }
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

    @DynamoDbAttribute("description")
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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
