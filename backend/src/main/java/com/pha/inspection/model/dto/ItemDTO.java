package com.pha.inspection.model.dto;

/**
 * DTO for Inspection Item API responses
 */
public class ItemDTO {

    private String itemId;
    private String description;
    private Integer sortOrder;
    private Boolean isActive;

    public ItemDTO() {
    }

    public ItemDTO(String itemId, String description, Integer sortOrder, Boolean isActive) {
        this.itemId = itemId;
        this.description = description;
        this.sortOrder = sortOrder;
        this.isActive = isActive;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
