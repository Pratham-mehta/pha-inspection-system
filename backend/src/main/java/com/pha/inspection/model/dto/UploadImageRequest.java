package com.pha.inspection.model.dto;

import jakarta.validation.constraints.NotBlank;

public class UploadImageRequest {
    @NotBlank(message = "SO Number is required")
    private String soNumber;

    private String itemId; // Optional - null means inspection-level image

    private String caption; // Optional

    @NotBlank(message = "Image data is required")
    private String imageData; // Base64 encoded

    @NotBlank(message = "MIME type is required")
    private String mimeType;

    @NotBlank(message = "File name is required")
    private String fileName;

    public UploadImageRequest() {
    }

    public UploadImageRequest(String soNumber, String itemId, String caption,
                             String imageData, String mimeType, String fileName) {
        this.soNumber = soNumber;
        this.itemId = itemId;
        this.caption = caption;
        this.imageData = imageData;
        this.mimeType = mimeType;
        this.fileName = fileName;
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

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    public String getImageData() {
        return imageData;
    }

    public void setImageData(String imageData) {
        this.imageData = imageData;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
}
