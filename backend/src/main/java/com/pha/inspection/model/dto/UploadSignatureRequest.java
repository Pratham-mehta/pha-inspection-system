package com.pha.inspection.model.dto;

import jakarta.validation.constraints.NotBlank;

public class UploadSignatureRequest {
    @NotBlank(message = "SO Number is required")
    private String soNumber;

    @NotBlank(message = "Signature type is required")
    private String signatureType; // "inspector" or "tenant"

    @NotBlank(message = "Signed by is required")
    private String signedBy;

    @NotBlank(message = "Signature data is required")
    private String signatureData; // Base64 encoded PNG

    @NotBlank(message = "File name is required")
    private String fileName;

    public UploadSignatureRequest() {
    }

    public UploadSignatureRequest(String soNumber, String signatureType, String signedBy,
                                  String signatureData, String fileName) {
        this.soNumber = soNumber;
        this.signatureType = signatureType;
        this.signedBy = signedBy;
        this.signatureData = signatureData;
        this.fileName = fileName;
    }

    public String getSoNumber() {
        return soNumber;
    }

    public void setSoNumber(String soNumber) {
        this.soNumber = soNumber;
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

    public String getSignatureData() {
        return signatureData;
    }

    public void setSignatureData(String signatureData) {
        this.signatureData = signatureData;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
}
