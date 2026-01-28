package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * PMI Response entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION#{soNumber}
 * SK: PMI#{itemId}
 */
@DynamoDbBean
public class PMIResponse {

    private String PK;              // INSPECTION#{soNumber}
    private String SK;              // PMI#{itemId}
    private String entityType;      // "PMIResponse"

    private String soNumber;        // Parent inspection SO number
    private String itemId;          // PMI item ID (e.g., "PMI001", "PMI002")
    private String categoryId;      // PMI category ID
    private Boolean completed;      // true/false
    private String notes;           // Optional notes about the task
    private String createdAt;

    public PMIResponse() {
        this.entityType = "PMIResponse";
        this.completed = false;
    }

    public PMIResponse(String soNumber, String itemId, String categoryId) {
        this();
        this.soNumber = soNumber;
        this.itemId = itemId;
        this.categoryId = categoryId;
        this.PK = "INSPECTION#" + soNumber;
        this.SK = "PMI#" + itemId;
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
            this.SK = "PMI#" + itemId;
        }
    }

    @DynamoDbAttribute("categoryId")
    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    @DynamoDbAttribute("completed")
    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }

    @DynamoDbAttribute("notes")
    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @DynamoDbAttribute("createdAt")
    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
}
