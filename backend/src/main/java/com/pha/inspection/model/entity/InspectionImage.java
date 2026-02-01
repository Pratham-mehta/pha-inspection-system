package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * Inspection Image entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION#{soNumber}
 * SK: IMAGE#{imageId}
 */
@DynamoDbBean
public class InspectionImage {

    private String PK;              // INSPECTION#{soNumber}
    private String SK;              // IMAGE#{imageId}
    private String entityType;      // "InspectionImage"

    private String imageId;
    private String soNumber;
    private String itemId;          // Optional - which inspection item this image belongs to
    private String imageUrl;        // S3 URL (or mock URL)
    private String thumbnailUrl;    // S3 thumbnail URL (or mock URL)
    private String caption;         // Optional caption
    private String uploadedAt;      // ISO timestamp
    private Integer fileSize;       // Size in bytes
    private String mimeType;        // image/jpeg, image/png, etc.

    public InspectionImage() {
        this.entityType = "InspectionImage";
    }

    public InspectionImage(String soNumber, String imageId) {
        this();
        this.soNumber = soNumber;
        this.imageId = imageId;
        this.PK = "INSPECTION#" + soNumber;
        this.SK = "IMAGE#" + imageId;
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

    @DynamoDbAttribute("imageId")
    public String getImageId() {
        return imageId;
    }

    public void setImageId(String imageId) {
        this.imageId = imageId;
        if (imageId != null) {
            this.SK = "IMAGE#" + imageId;
        }
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
    }

    @DynamoDbAttribute("imageUrl")
    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    @DynamoDbAttribute("thumbnailUrl")
    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    @DynamoDbAttribute("caption")
    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    @DynamoDbAttribute("uploadedAt")
    public String getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(String uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    @DynamoDbAttribute("fileSize")
    public Integer getFileSize() {
        return fileSize;
    }

    public void setFileSize(Integer fileSize) {
        this.fileSize = fileSize;
    }

    @DynamoDbAttribute("mimeType")
    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }
}
