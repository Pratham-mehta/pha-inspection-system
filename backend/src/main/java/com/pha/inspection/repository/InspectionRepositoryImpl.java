package com.pha.inspection.repository;

import com.pha.inspection.model.entity.Inspection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryConditional;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryEnhancedRequest;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * DynamoDB implementation of InspectionRepository
 *
 * Uses AWS DynamoDB Enhanced Client with Global Secondary Indexes for efficient querying:
 * - GSI1: For querying inspections by unit
 * - GSI2: For querying inspections by status and date
 * - GSI3: For querying inspections by inspector
 */
@Component
public class InspectionRepositoryImpl implements InspectionRepository {

    private final DynamoDbTable<Inspection> inspectionTable;

    @Autowired
    public InspectionRepositoryImpl(DynamoDbEnhancedClient enhancedClient,
                                    @Value("${aws.dynamodb.table-name}") String tableName) {
        this.inspectionTable = enhancedClient.table(tableName, TableSchema.fromBean(Inspection.class));
    }

    @Override
    public Inspection save(Inspection inspection) {
        try {
            // Initialize GSI attributes (GSI1PK, GSI2PK, GSI3PK) before saving
            inspection.initializeGSI();
            inspection.setUpdatedAt(Instant.now().toString());
            inspectionTable.putItem(inspection);
            return inspection;
        } catch (Exception e) {
            throw new RuntimeException("Error saving inspection: " + inspection.getSoNumber(), e);
        }
    }

    @Override
    public Optional<Inspection> findBySoNumber(String soNumber) {
        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTION#" + soNumber)
                    .sortValue("METADATA")
                    .build();
            Inspection inspection = inspectionTable.getItem(key);
            return Optional.ofNullable(inspection);
        } catch (Exception e) {
            throw new RuntimeException("Error finding inspection: " + soNumber, e);
        }
    }

    @Override
    public List<Inspection> findAll() {
        try {
            // Use scan to get all inspections
            // For large datasets, consider pagination or filtering
            return inspectionTable.scan().items().stream().collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Error finding all inspections", e);
        }
    }

    @Override
    public List<Inspection> findByStatus(String status) {
        try {
            // Use GSI2: GSI2PK = STATUS#{status}
            // This allows efficient querying by status
            QueryEnhancedRequest query = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.keyEqualTo(
                            Key.builder().partitionValue("STATUS#" + status).build()))
                    .build();

            return inspectionTable.index("GSI2")
                    .query(query)
                    .stream()
                    .flatMap(page -> page.items().stream())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Error finding inspections by status: " + status, e);
        }
    }

    @Override
    public List<Inspection> findBySiteCode(String siteCode) {
        try {
            // Scan with filter - no GSI for site code
            // For better performance, consider adding GSI4 for site code in production
            return inspectionTable.scan().items().stream()
                    .filter(i -> siteCode.equals(i.getSiteCode()))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Error finding inspections by site code: " + siteCode, e);
        }
    }

    @Override
    public List<Inspection> findByInspectorId(String inspectorId) {
        try {
            // Use GSI3: GSI3PK = INSPECTOR#{inspectorId}
            // This allows efficient querying by assigned inspector
            QueryEnhancedRequest query = QueryEnhancedRequest.builder()
                    .queryConditional(QueryConditional.keyEqualTo(
                            Key.builder().partitionValue("INSPECTOR#" + inspectorId).build()))
                    .build();

            return inspectionTable.index("GSI3")
                    .query(query)
                    .stream()
                    .flatMap(page -> page.items().stream())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Error finding inspections by inspector: " + inspectorId, e);
        }
    }

    @Override
    public void deleteBySoNumber(String soNumber) {
        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTION#" + soNumber)
                    .sortValue("METADATA")
                    .build();
            inspectionTable.deleteItem(key);
        } catch (Exception e) {
            throw new RuntimeException("Error deleting inspection: " + soNumber, e);
        }
    }

    @Override
    public long count() {
        try {
            // Use scan to count all inspections
            // For large datasets, use DynamoDB's describe-table API for approximate count
            return inspectionTable.scan().items().stream().count();
        } catch (Exception e) {
            throw new RuntimeException("Error counting inspections", e);
        }
    }
}
