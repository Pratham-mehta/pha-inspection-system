package com.pha.inspection.service;

import com.pha.inspection.model.dto.InspectionImageDTO;
import com.pha.inspection.model.dto.UploadImageRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class ImageService {
    private static final Logger log = LoggerFactory.getLogger(ImageService.class);

    // In-memory storage for Phase 9 (replace with S3/database in Phase 10)
    private final Map<String, InspectionImageDTO> images = new ConcurrentHashMap<>();

    // MARK: - Upload Image
    public InspectionImageDTO uploadImage(UploadImageRequest request) {
        log.info("Uploading image for SO: {}, Item: {}", request.getSoNumber(), request.getItemId());

        // Generate image ID
        String imageId = "IMG" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        // In production, decode base64 and upload to S3
        // For now, store metadata only
        String timestamp = ZonedDateTime.now().format(DateTimeFormatter.ISO_INSTANT);

        // Mock image URL (in production, this would be S3 URL)
        String imageUrl = "https://mock-storage.com/images/" + imageId + ".jpg";
        String thumbnailUrl = "https://mock-storage.com/thumbnails/" + imageId + "_thumb.jpg";

        // Calculate mock file size from base64 length
        int estimatedSize = (int) (request.getImageData().length() * 0.75);

        InspectionImageDTO imageDTO = new InspectionImageDTO(
                imageId,
                request.getSoNumber(),
                request.getItemId(),
                imageUrl,
                thumbnailUrl,
                request.getCaption(),
                timestamp,
                estimatedSize,
                request.getMimeType()
        );

        images.put(imageId, imageDTO);
        log.info("Image uploaded successfully: {}", imageId);

        return imageDTO;
    }

    // MARK: - Get Images by Inspection
    public List<InspectionImageDTO> getImagesByInspection(String soNumber) {
        log.info("Getting images for SO: {}", soNumber);

        return images.values().stream()
                .filter(img -> img.getSoNumber().equals(soNumber))
                .sorted(Comparator.comparing(InspectionImageDTO::getUploadedAt).reversed())
                .collect(Collectors.toList());
    }

    // MARK: - Get Image by ID
    public InspectionImageDTO getImageById(String soNumber, String imageId) {
        log.info("Getting image: {} for SO: {}", imageId, soNumber);

        InspectionImageDTO image = images.get(imageId);
        if (image == null || !image.getSoNumber().equals(soNumber)) {
            throw new RuntimeException("Image not found: " + imageId);
        }

        return image;
    }

    // MARK: - Delete Image
    public void deleteImage(String soNumber, String imageId) {
        log.info("Deleting image: {} for SO: {}", imageId, soNumber);

        InspectionImageDTO image = images.get(imageId);
        if (image == null || !image.getSoNumber().equals(soNumber)) {
            throw new RuntimeException("Image not found: " + imageId);
        }

        images.remove(imageId);
        log.info("Image deleted successfully: {}", imageId);
    }

    // MARK: - Testing Methods (Phase 9 only)
    public void clearAll() {
        images.clear();
    }

    public int getImageCount() {
        return images.size();
    }
}
