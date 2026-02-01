package com.pha.inspection.repository;

import com.pha.inspection.model.entity.Inspector;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;

import java.util.Optional;

/**
 * Repository for Inspector operations
 *
 * ✅ DYNAMODB IMPLEMENTATION (Migrated from Phase 9 in-memory storage)
 *
 * This repository uses AWS DynamoDB Enhanced Client for persistent storage.
 * All inspector data is stored in the "pha-inspections" table with:
 * - Partition Key (PK): "INSPECTOR#{inspectorId}"
 * - Sort Key (SK): "METADATA"
 * - GSI1: For querying all inspectors by status/role (future enhancement)
 */
@Repository
public class InspectorRepository {

    private final DynamoDbTable<Inspector> inspectorTable;

    @Autowired
    public InspectorRepository(DynamoDbEnhancedClient enhancedClient,
                               @Value("${aws.dynamodb.table-name}") String tableName) {
        this.inspectorTable = enhancedClient.table(tableName, TableSchema.fromBean(Inspector.class));
    }

    /**
     * Find inspector by ID
     *
     * Uses DynamoDB getItem() with composite key:
     * - PK: "INSPECTOR#{inspectorId}"
     * - SK: "METADATA"
     */
    public Optional<Inspector> findByInspectorId(String inspectorId) {
        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTOR#" + inspectorId)
                    .sortValue("METADATA")
                    .build();

            Inspector inspector = inspectorTable.getItem(key);
            return Optional.ofNullable(inspector);
        } catch (Exception e) {
            throw new RuntimeException("Error finding inspector: " + inspectorId, e);
        }
    }

    /**
     * Save inspector
     *
     * Initializes DynamoDB keys (PK, SK, GSI1PK, GSI1SK) and persists to DynamoDB.
     * The initializeGSI() method sets:
     * - PK = "INSPECTOR#{inspectorId}"
     * - SK = "METADATA"
     * - GSI1PK = "INSPECTORS"
     * - GSI1SK = "INSPECTOR#{inspectorId}"
     */
    public Inspector save(Inspector inspector) {
        try {
            // Initialize GSI attributes before saving
            inspector.initializeGSI();
            inspectorTable.putItem(inspector);
            return inspector;
        } catch (Exception e) {
            throw new RuntimeException("Error saving inspector", e);
        }
    }

    /**
     * Delete inspector
     *
     * Deletes inspector from DynamoDB using composite key.
     */
    public void delete(String inspectorId) {
        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTOR#" + inspectorId)
                    .sortValue("METADATA")
                    .build();

            inspectorTable.deleteItem(key);
        } catch (Exception e) {
            throw new RuntimeException("Error deleting inspector: " + inspectorId, e);
        }
    }
}
