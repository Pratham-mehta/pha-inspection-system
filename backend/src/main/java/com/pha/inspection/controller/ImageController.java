package com.pha.inspection.controller;

import com.pha.inspection.model.dto.InspectionImageDTO;
import com.pha.inspection.model.dto.UploadImageRequest;
import com.pha.inspection.service.ImageService;
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
@RequestMapping("/inspections/{soNumber}/images")
@Tag(name = "Image Management", description = "Endpoints for inspection image upload and management")
@SecurityRequirement(name = "bearer-jwt")
public class ImageController {
    private static final Logger log = LoggerFactory.getLogger(ImageController.class);

    private final ImageService imageService;

    public ImageController(ImageService imageService) {
        this.imageService = imageService;
    }

    @PostMapping("/upload")
    @Operation(summary = "Upload inspection image", description = "Upload a new image for an inspection")
    public ResponseEntity<InspectionImageDTO> uploadImage(
            @PathVariable String soNumber,
            @Valid @RequestBody UploadImageRequest request
    ) {
        log.info("POST /inspections/{}/images/upload", soNumber);

        // Ensure SO number matches path parameter
        request.setSoNumber(soNumber);

        InspectionImageDTO image = imageService.uploadImage(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(image);
    }

    @GetMapping
    @Operation(summary = "Get all images for inspection", description = "Retrieve all images for a specific inspection")
    public ResponseEntity<List<InspectionImageDTO>> getImages(
            @PathVariable String soNumber
    ) {
        log.info("GET /inspections/{}/images", soNumber);

        List<InspectionImageDTO> images = imageService.getImagesByInspection(soNumber);
        return ResponseEntity.ok(images);
    }

    @GetMapping("/{imageId}")
    @Operation(summary = "Get single image", description = "Retrieve a specific image by ID")
    public ResponseEntity<InspectionImageDTO> getImage(
            @PathVariable String soNumber,
            @PathVariable String imageId
    ) {
        log.info("GET /inspections/{}/images/{}", soNumber, imageId);

        InspectionImageDTO image = imageService.getImageById(soNumber, imageId);
        return ResponseEntity.ok(image);
    }

    @DeleteMapping("/{imageId}")
    @Operation(summary = "Delete image", description = "Delete a specific image")
    public ResponseEntity<Void> deleteImage(
            @PathVariable String soNumber,
            @PathVariable String imageId
    ) {
        log.info("DELETE /inspections/{}/images/{}", soNumber, imageId);

        imageService.deleteImage(soNumber, imageId);
        return ResponseEntity.noContent().build();
    }
}
