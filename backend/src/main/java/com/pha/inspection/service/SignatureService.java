package com.pha.inspection.service;

import com.pha.inspection.model.dto.InspectionSignatureDTO;
import com.pha.inspection.model.dto.UploadSignatureRequest;
import com.pha.inspection.model.entity.InspectionSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryConditional;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryEnhancedRequest;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class SignatureService {
    private static final Logger log = LoggerFactory.getLogger(SignatureService.class);

    private final DynamoDbTable<InspectionSignature> signatureTable;

    @Autowired
    public SignatureService(DynamoDbEnhancedClient dynamoDbEnhancedClient) {
        this.signatureTable = dynamoDbEnhancedClient.table("pha-inspections", TableSchema.fromBean(InspectionSignature.class));
        log.info("SignatureService initialized with DynamoDB table: pha-inspections");
    }

    // MARK: - Upload Signature
    public InspectionSignatureDTO uploadSignature(UploadSignatureRequest request) {
        log.info("Uploading signature for SO: {}, Type: {}, Signed by: {}",
                request.getSoNumber(), request.getSignatureType(), request.getSignedBy());

        try {
            // Generate signature ID
            String signatureId = "SIG" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            // In production, decode base64 and upload to S3
            // For now, store metadata only
            String timestamp = ZonedDateTime.now().format(DateTimeFormatter.ISO_INSTANT);

            // Mock signature URL (in production, this would be S3 URL)
            String signatureUrl = "https://mock-storage.com/signatures/" + signatureId + ".png";

            // Calculate mock file size from base64 length
            int estimatedSize = (int) (request.getSignatureData().length() * 0.75);

            // Create entity
            InspectionSignature signature = new InspectionSignature(request.getSoNumber(), signatureId);
            signature.setSignatureUrl(signatureUrl);
            signature.setSignatureType(request.getSignatureType());
            signature.setSignedBy(request.getSignedBy());
            signature.setSignedAt(timestamp);
            signature.setFileSize(estimatedSize);

            // Save to DynamoDB
            signatureTable.putItem(signature);

            log.info("Signature uploaded successfully to DynamoDB: {}", signatureId);

            return convertToDTO(signature);
        } catch (Exception e) {
            log.error("Error uploading signature for SO: {}", request.getSoNumber(), e);
            throw new RuntimeException("Failed to upload signature", e);
        }
    }

    // MARK: - Get Signatures by Inspection
    public List<InspectionSignatureDTO> getSignaturesByInspection(String soNumber) {
        log.info("Getting signatures for SO: {}", soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;

            QueryEnhancedRequest queryRequest = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.keyEqualTo(Key.builder()
                            .partitionValue(pk)
                            .build()))
                    .build();

            List<InspectionSignature> signatures = signatureTable.query(queryRequest).stream()
                    .flatMap(page -> page.items().stream())
                    .filter(sig -> sig.getSK() != null && sig.getSK().startsWith("SIGNATURE#"))
                    .sorted(Comparator.comparing(InspectionSignature::getSignedAt).reversed())
                    .collect(Collectors.toList());

            log.info("Found {} signatures for SO: {}", signatures.size(), soNumber);

            return signatures.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Error getting signatures for SO: {}", soNumber, e);
            throw new RuntimeException("Failed to get signatures", e);
        }
    }

    // MARK: - Get Signature by ID
    public InspectionSignatureDTO getSignatureById(String soNumber, String signatureId) {
        log.info("Getting signature: {} for SO: {}", signatureId, soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "SIGNATURE#" + signatureId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            InspectionSignature signature = signatureTable.getItem(key);

            if (signature == null) {
                throw new RuntimeException("Signature not found: " + signatureId);
            }

            log.info("Signature found: {}", signatureId);
            return convertToDTO(signature);
        } catch (Exception e) {
            log.error("Error getting signature: {} for SO: {}", signatureId, soNumber, e);
            throw new RuntimeException("Failed to get signature", e);
        }
    }

    // MARK: - Delete Signature
    public void deleteSignature(String soNumber, String signatureId) {
        log.info("Deleting signature: {} for SO: {}", signatureId, soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "SIGNATURE#" + signatureId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            InspectionSignature deleted = signatureTable.deleteItem(key);

            if (deleted == null) {
                throw new RuntimeException("Signature not found: " + signatureId);
            }

            log.info("Signature deleted successfully from DynamoDB: {}", signatureId);
        } catch (Exception e) {
            log.error("Error deleting signature: {} for SO: {}", signatureId, soNumber, e);
            throw new RuntimeException("Failed to delete signature", e);
        }
    }

    /**
     * Convert entity to DTO
     */
    private InspectionSignatureDTO convertToDTO(InspectionSignature signature) {
        return new InspectionSignatureDTO(
                signature.getSignatureId(),
                signature.getSoNumber(),
                signature.getSignatureUrl(),
                signature.getSignatureType(),
                signature.getSignedBy(),
                signature.getSignedAt(),
                signature.getFileSize()
        );
    }
}
