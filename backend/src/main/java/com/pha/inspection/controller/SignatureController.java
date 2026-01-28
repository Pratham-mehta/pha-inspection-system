package com.pha.inspection.controller;

import com.pha.inspection.model.dto.InspectionSignatureDTO;
import com.pha.inspection.model.dto.UploadSignatureRequest;
import com.pha.inspection.service.SignatureService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/inspections/{soNumber}/signatures")
@Tag(name = "Signature Management", description = "Endpoints for inspection signature upload and management")
@SecurityRequirement(name = "bearer-jwt")
public class SignatureController {
    private static final Logger log = LoggerFactory.getLogger(SignatureController.class);

    private final SignatureService signatureService;

    public SignatureController(SignatureService signatureService) {
        this.signatureService = signatureService;
    }

    @PostMapping("/upload")
    @Operation(summary = "Upload inspection signature", description = "Upload a new signature for an inspection")
    public ResponseEntity<InspectionSignatureDTO> uploadSignature(
            @PathVariable String soNumber,
            @Valid @RequestBody UploadSignatureRequest request
    ) {
        log.info("POST /inspections/{}/signatures/upload", soNumber);

        // Ensure SO number matches path parameter
        request.setSoNumber(soNumber);

        InspectionSignatureDTO signature = signatureService.uploadSignature(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(signature);
    }

    @GetMapping
    @Operation(summary = "Get all signatures for inspection", description = "Retrieve all signatures for a specific inspection")
    public ResponseEntity<List<InspectionSignatureDTO>> getSignatures(
            @PathVariable String soNumber
    ) {
        log.info("GET /inspections/{}/signatures", soNumber);

        List<InspectionSignatureDTO> signatures = signatureService.getSignaturesByInspection(soNumber);
        return ResponseEntity.ok(signatures);
    }

    @GetMapping("/{signatureId}")
    @Operation(summary = "Get single signature", description = "Retrieve a specific signature by ID")
    public ResponseEntity<InspectionSignatureDTO> getSignature(
            @PathVariable String soNumber,
            @PathVariable String signatureId
    ) {
        log.info("GET /inspections/{}/signatures/{}", soNumber, signatureId);

        InspectionSignatureDTO signature = signatureService.getSignatureById(soNumber, signatureId);
        return ResponseEntity.ok(signature);
    }

    @DeleteMapping("/{signatureId}")
    @Operation(summary = "Delete signature", description = "Delete a specific signature")
    public ResponseEntity<Void> deleteSignature(
            @PathVariable String soNumber,
            @PathVariable String signatureId
    ) {
        log.info("DELETE /inspections/{}/signatures/{}", soNumber, signatureId);

        signatureService.deleteSignature(soNumber, signatureId);
        return ResponseEntity.noContent().build();
    }
}
