package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * PMI Item entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: PMI_CATEGORY#{categoryId}
 * SK: ITEM#{itemId}
 */
@DynamoDbBean
public class PMIItem {

    private String PK;              // PMI_CATEGORY#{categoryId}
    private String SK;              // ITEM#{itemId}
    private String entityType;      // "PMIItem"

    private String categoryId;
    private String itemId;
    private String description;
    private Integer sortOrder;
    private Boolean isActive;
    private String createdAt;

    public PMIItem() {
        this.entityType = "PMIItem";
        this.isActive = true;
    }

    public PMIItem(String categoryId, String itemId, String description, Integer sortOrder) {
        this();
        this.categoryId = categoryId;
        this.itemId = itemId;
        this.description = description;
        this.sortOrder = sortOrder;
        this.PK = "PMI_CATEGORY#" + categoryId;
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

    @DynamoDbAttribute("categoryId")
    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
        if (categoryId != null) {
            this.PK = "PMI_CATEGORY#" + categoryId;
        }
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

    @DynamoDbAttribute("createdAt")
    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
