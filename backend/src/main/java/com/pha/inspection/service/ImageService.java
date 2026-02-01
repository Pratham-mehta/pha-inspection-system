package com.pha.inspection.service;

import com.pha.inspection.model.dto.InspectionImageDTO;
import com.pha.inspection.model.dto.UploadImageRequest;
import com.pha.inspection.model.entity.InspectionImage;
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
public class ImageService {
    private static final Logger log = LoggerFactory.getLogger(ImageService.class);

    private final DynamoDbTable<InspectionImage> imageTable;

    @Autowired
    public ImageService(DynamoDbEnhancedClient dynamoDbEnhancedClient) {
        this.imageTable = dynamoDbEnhancedClient.table("pha-inspections", TableSchema.fromBean(InspectionImage.class));
        log.info("ImageService initialized with DynamoDB table: pha-inspections");
    }

    // MARK: - Upload Image
    public InspectionImageDTO uploadImage(UploadImageRequest request) {
        log.info("Uploading image for SO: {}, Item: {}", request.getSoNumber(), request.getItemId());

        try {
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

            // Create entity
            InspectionImage image = new InspectionImage(request.getSoNumber(), imageId);
            image.setItemId(request.getItemId());
            image.setImageUrl(imageUrl);
            image.setThumbnailUrl(thumbnailUrl);
            image.setCaption(request.getCaption());
            image.setUploadedAt(timestamp);
            image.setFileSize(estimatedSize);
            image.setMimeType(request.getMimeType());

            // Save to DynamoDB
            imageTable.putItem(image);

            log.info("Image uploaded successfully to DynamoDB: {}", imageId);

            return convertToDTO(image);
        } catch (Exception e) {
            log.error("Error uploading image for SO: {}", request.getSoNumber(), e);
            throw new RuntimeException("Failed to upload image", e);
        }
    }

    // MARK: - Get Images by Inspection
    public List<InspectionImageDTO> getImagesByInspection(String soNumber) {
        log.info("Getting images for SO: {}", soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;

            QueryEnhancedRequest queryRequest = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.keyEqualTo(Key.builder()
                            .partitionValue(pk)
                            .build()))
                    .build();

            List<InspectionImage> images = imageTable.query(queryRequest).stream()
                    .flatMap(page -> page.items().stream())
                    .filter(img -> img.getSK() != null && img.getSK().startsWith("IMAGE#"))
                    .sorted(Comparator.comparing(InspectionImage::getUploadedAt).reversed())
                    .collect(Collectors.toList());

            log.info("Found {} images for SO: {}", images.size(), soNumber);

            return images.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Error getting images for SO: {}", soNumber, e);
            throw new RuntimeException("Failed to get images", e);
        }
    }

    // MARK: - Get Image by ID
    public InspectionImageDTO getImageById(String soNumber, String imageId) {
        log.info("Getting image: {} for SO: {}", imageId, soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "IMAGE#" + imageId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            InspectionImage image = imageTable.getItem(key);

            if (image == null) {
                throw new RuntimeException("Image not found: " + imageId);
            }

            log.info("Image found: {}", imageId);
            return convertToDTO(image);
        } catch (Exception e) {
            log.error("Error getting image: {} for SO: {}", imageId, soNumber, e);
            throw new RuntimeException("Failed to get image", e);
        }
    }

    // MARK: - Delete Image
    public void deleteImage(String soNumber, String imageId) {
        log.info("Deleting image: {} for SO: {}", imageId, soNumber);

        try {
            String pk = "INSPECTION#" + soNumber;
            String sk = "IMAGE#" + imageId;

            Key key = Key.builder()
                    .partitionValue(pk)
                    .sortValue(sk)
                    .build();

            InspectionImage deleted = imageTable.deleteItem(key);

            if (deleted == null) {
                throw new RuntimeException("Image not found: " + imageId);
            }

            log.info("Image deleted successfully from DynamoDB: {}", imageId);
        } catch (Exception e) {
            log.error("Error deleting image: {} for SO: {}", imageId, soNumber, e);
            throw new RuntimeException("Failed to delete image", e);
        }
    }

    /**
     * Convert entity to DTO
     */
    private InspectionImageDTO convertToDTO(InspectionImage image) {
        return new InspectionImageDTO(
                image.getImageId(),
                image.getSoNumber(),
                image.getItemId(),
                image.getImageUrl(),
                image.getThumbnailUrl(),
                image.getCaption(),
                image.getUploadedAt(),
                image.getFileSize(),
                image.getMimeType()
        );
    }
}
