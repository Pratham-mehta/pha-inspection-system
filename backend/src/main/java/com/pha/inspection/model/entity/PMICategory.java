package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * PMI Category entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: PMI_CATEGORY
 * SK: CATEGORY#{categoryId}
 */
@DynamoDbBean
public class PMICategory {

    private String PK;              // PMI_CATEGORY
    private String SK;              // CATEGORY#{categoryId}
    private String entityType;      // "PMICategory"

    private String categoryId;
    private String name;
    private Integer sortOrder;
    private Boolean isActive;
    private String createdAt;

    public PMICategory() {
        this.entityType = "PMICategory";
        this.PK = "PMI_CATEGORY";
        this.isActive = true;
    }

    public PMICategory(String categoryId, String name, Integer sortOrder) {
        this();
        this.categoryId = categoryId;
        this.name = name;
        this.sortOrder = sortOrder;
        this.SK = "CATEGORY#" + categoryId;
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
            this.SK = "CATEGORY#" + categoryId;
        }
    }

    @DynamoDbAttribute("name")
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
