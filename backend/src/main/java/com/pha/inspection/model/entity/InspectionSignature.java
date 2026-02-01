package com.pha.inspection.model.entity;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;

/**
 * Inspection Signature entity for DynamoDB
 *
 * DynamoDB Structure:
 * PK: INSPECTION#{soNumber}
 * SK: SIGNATURE#{signatureId}
 */
@DynamoDbBean
public class InspectionSignature {

    private String PK;              // INSPECTION#{soNumber}
    private String SK;              // SIGNATURE#{signatureId}
    private String entityType;      // "InspectionSignature"

    private String signatureId;
    private String soNumber;
    private String signatureUrl;    // S3 URL (or mock URL)
    private String signatureType;   // "inspector" or "tenant"
    private String signedBy;        // Name of person who signed
    private String signedAt;        // ISO timestamp
    private Integer fileSize;       // Size in bytes

    public InspectionSignature() {
        this.entityType = "InspectionSignature";
    }

    public InspectionSignature(String soNumber, String signatureId) {
        this();
        this.soNumber = soNumber;
        this.signatureId = signatureId;
        this.PK = "INSPECTION#" + soNumber;
        this.SK = "SIGNATURE#" + signatureId;
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

    @DynamoDbAttribute("signatureId")
    public String getSignatureId() {
        return signatureId;
    }

    public void setSignatureId(String signatureId) {
        this.signatureId = signatureId;
        if (signatureId != null) {
            this.SK = "SIGNATURE#" + signatureId;
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

    @DynamoDbAttribute("signatureUrl")
    public String getSignatureUrl() {
        return signatureUrl;
    }

    public void setSignatureUrl(String signatureUrl) {
        this.signatureUrl = signatureUrl;
    }

    @DynamoDbAttribute("signatureType")
    public String getSignatureType() {
        return signatureType;
    }

    public void setSignatureType(String signatureType) {
        this.signatureType = signatureType;
    }

    @DynamoDbAttribute("signedBy")
    public String getSignedBy() {
        return signedBy;
    }

    public void setSignedBy(String signedBy) {
        this.signedBy = signedBy;
    }

    @DynamoDbAttribute("signedAt")
    public String getSignedAt() {
        return signedAt;
    }

    public void setSignedAt(String signedAt) {
        this.signedAt = signedAt;
    }

    @DynamoDbAttribute("fileSize")
    public Integer getFileSize() {
        return fileSize;
    }

    public void setFileSize(Integer fileSize) {
        this.fileSize = fileSize;
    }
}
