package com.pha.inspection.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class InspectionImageDTO {
    @JsonProperty("imageId")
    private String id;
    private String soNumber;
    private String itemId;
    private String imageUrl;
    private String thumbnailUrl;
    private String caption;
    private String uploadedAt;
    private Integer fileSize;
    private String mimeType;

    public InspectionImageDTO() {
    }

    public InspectionImageDTO(String id, String soNumber, String itemId, String imageUrl,
                             String thumbnailUrl, String caption, String uploadedAt,
                             Integer fileSize, String mimeType) {
        this.id = id;
        this.soNumber = soNumber;
        this.itemId = itemId;
        this.imageUrl = imageUrl;
        this.thumbnailUrl = thumbnailUrl;
        this.caption = caption;
        this.uploadedAt = uploadedAt;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSoNumber() {
        return soNumber;
    }

    public void setSoNumber(String soNumber) {
        this.soNumber = soNumber;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public String getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(String uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    public Integer getFileSize() {
        return fileSize;
    }

    public void setFileSize(Integer fileSize) {
        this.fileSize = fileSize;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }
}
