package com.pha.inspection.model.dto;

/**
 * DTO for creating/updating PMI response
 */
public class CreatePMIResponseRequest {

    private String itemId;
    private String categoryId;
    private Boolean completed;
    private String notes;

    public CreatePMIResponseRequest() {
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
