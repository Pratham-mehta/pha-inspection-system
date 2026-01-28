package com.pha.inspection.model.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class InspectionSignatureDTO {
    @JsonProperty("signatureId")
    private String id;
    private String soNumber;
    private String signatureUrl;
    private String signatureType; // "inspector" or "tenant"
    private String signedBy;
    private String signedAt;
    private Integer fileSize;

    public InspectionSignatureDTO() {
    }

    public InspectionSignatureDTO(String id, String soNumber, String signatureUrl,
                                  String signatureType, String signedBy, String signedAt,
                                  Integer fileSize) {
        this.id = id;
        this.soNumber = soNumber;
        this.signatureUrl = signatureUrl;
        this.signatureType = signatureType;
        this.signedBy = signedBy;
        this.signedAt = signedAt;
        this.fileSize = fileSize;
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

    public String getSignatureUrl() {
        return signatureUrl;
    }

    public void setSignatureUrl(String signatureUrl) {
        this.signatureUrl = signatureUrl;
    }

    public String getSignatureType() {
        return signatureType;
    }

    public void setSignatureType(String signatureType) {
        this.signatureType = signatureType;
    }

    public String getSignedBy() {
        return signedBy;
    }

    public void setSignedBy(String signedBy) {
        this.signedBy = signedBy;
    }

    public String getSignedAt() {
        return signedAt;
    }

    public void setSignedAt(String signedAt) {
        this.signedAt = signedAt;
    }

    public Integer getFileSize() {
        return fileSize;
    }

    public void setFileSize(Integer fileSize) {
        this.fileSize = fileSize;
    }
}
