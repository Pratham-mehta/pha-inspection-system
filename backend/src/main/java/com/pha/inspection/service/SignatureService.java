package com.pha.inspection.service;

import com.pha.inspection.model.dto.InspectionSignatureDTO;
import com.pha.inspection.model.dto.UploadSignatureRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class SignatureService {
    private static final Logger log = LoggerFactory.getLogger(SignatureService.class);

    // In-memory storage for Phase 9 (replace with S3/database in Phase 10)
    private final Map<String, InspectionSignatureDTO> signatures = new ConcurrentHashMap<>();

    // MARK: - Upload Signature
    public InspectionSignatureDTO uploadSignature(UploadSignatureRequest request) {
        log.info("Uploading signature for SO: {}, Type: {}, Signed by: {}",
                request.getSoNumber(), request.getSignatureType(), request.getSignedBy());

        // Generate signature ID
        String signatureId = "SIG" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        // In production, decode base64 and upload to S3
        // For now, store metadata only
        String timestamp = ZonedDateTime.now().format(DateTimeFormatter.ISO_INSTANT);

        // Mock signature URL (in production, this would be S3 URL)
        String signatureUrl = "https://mock-storage.com/signatures/" + signatureId + ".png";

        // Calculate mock file size from base64 length
        int estimatedSize = (int) (request.getSignatureData().length() * 0.75);

        InspectionSignatureDTO signatureDTO = new InspectionSignatureDTO(
                signatureId,
                request.getSoNumber(),
                signatureUrl,
                request.getSignatureType(),
                request.getSignedBy(),
                timestamp,
                estimatedSize
        );

        signatures.put(signatureId, signatureDTO);
        log.info("Signature uploaded successfully: {}", signatureId);

        return signatureDTO;
    }

    // MARK: - Get Signatures by Inspection
    public List<InspectionSignatureDTO> getSignaturesByInspection(String soNumber) {
        log.info("Getting signatures for SO: {}", soNumber);

        return signatures.values().stream()
                .filter(sig -> sig.getSoNumber().equals(soNumber))
                .sorted(Comparator.comparing(InspectionSignatureDTO::getSignedAt).reversed())
                .collect(Collectors.toList());
    }

    // MARK: - Get Signature by ID
    public InspectionSignatureDTO getSignatureById(String soNumber, String signatureId) {
        log.info("Getting signature: {} for SO: {}", signatureId, soNumber);

        InspectionSignatureDTO signature = signatures.get(signatureId);
        if (signature == null || !signature.getSoNumber().equals(soNumber)) {
            throw new RuntimeException("Signature not found: " + signatureId);
        }

        return signature;
    }

    // MARK: - Delete Signature
    public void deleteSignature(String soNumber, String signatureId) {
        log.info("Deleting signature: {} for SO: {}", signatureId, soNumber);

        InspectionSignatureDTO signature = signatures.get(signatureId);
        if (signature == null || !signature.getSoNumber().equals(soNumber)) {
            throw new RuntimeException("Signature not found: " + signatureId);
        }

        signatures.remove(signatureId);
        log.info("Signature deleted successfully: {}", signatureId);
    }

    // MARK: - Testing Methods (Phase 9 only)
    public void clearAll() {
        signatures.clear();
    }

    public int getSignatureCount() {
        return signatures.size();
    }
}
