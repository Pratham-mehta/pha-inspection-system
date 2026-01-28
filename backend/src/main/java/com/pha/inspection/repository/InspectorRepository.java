package com.pha.inspection.repository;

import com.pha.inspection.model.entity.Inspector;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Repository for Inspector operations
 *
 * ⚠️ PHASE 9 IMPLEMENTATION: IN-MEMORY STORAGE ⚠️
 *
 * This repository uses ConcurrentHashMap for in-memory storage during Phase 9 (Frontend Development).
 * This allows frontend-backend integration testing without requiring DynamoDB setup.
 *
 * 🔄 MIGRATION TO DYNAMODB (PHASE 10 - DEPLOYMENT):
 * To switch to DynamoDB for production:
 *
 * 1. UNCOMMENT the DynamoDB imports below:
 *    - import org.springframework.beans.factory.annotation.Autowired;
 *    - import org.springframework.beans.factory.annotation.Value;
 *    - import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
 *    - import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
 *    - import software.amazon.awssdk.enhanced.dynamodb.Key;
 *    - import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
 *
 * 2. REPLACE the in-memory storage field with:
 *    private final DynamoDbTable<Inspector> inspectorTable;
 *
 * 3. REPLACE the constructor with:
 *    @Autowired
 *    public InspectorRepository(DynamoDbEnhancedClient enhancedClient,
 *                               @Value("${aws.dynamodb.table-name}") String tableName) {
 *        this.inspectorTable = enhancedClient.table(tableName, TableSchema.fromBean(Inspector.class));
 *    }
 *
 * 4. REPLACE each method implementation:
 *    - findByInspectorId(): Use inspectorTable.getItem() with Key.builder()
 *    - save(): Use inspectorTable.putItem() with inspector.initializeGSI()
 *    - delete(): Use inspectorTable.deleteItem() with Key.builder()
 *
 * 5. See DYNAMODB_MIGRATION_GUIDE.md for complete implementation
 *
 * NOTE: The original DynamoDB implementation is preserved in git history
 * Commit: [Will be added when committed]
 */
@Repository
public class InspectorRepository {

    // ========================================
    // IN-MEMORY STORAGE (PHASE 9)
    // ========================================
    // REMOVE THIS SECTION FOR DYNAMODB (PHASE 10)
    private final Map<String, Inspector> inspectorStore = new ConcurrentHashMap<>();

    /**
     * Find inspector by ID
     *
     * IN-MEMORY IMPLEMENTATION (Phase 9)
     * For DynamoDB: Use inspectorTable.getItem() with partition key "INSPECTOR#" + inspectorId
     */
    public Optional<Inspector> findByInspectorId(String inspectorId) {
        return Optional.ofNullable(inspectorStore.get(inspectorId));

        /* DYNAMODB IMPLEMENTATION (PHASE 10 - UNCOMMENT THIS):
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
        */
    }

    /**
     * Save inspector
     *
     * IN-MEMORY IMPLEMENTATION (Phase 9)
     * For DynamoDB: Use inspectorTable.putItem() after calling inspector.initializeGSI()
     */
    public Inspector save(Inspector inspector) {
        inspectorStore.put(inspector.getInspectorId(), inspector);
        return inspector;

        /* DYNAMODB IMPLEMENTATION (PHASE 10 - UNCOMMENT THIS):
        try {
            // Initialize GSI attributes before saving
            inspector.initializeGSI();
            inspectorTable.putItem(inspector);
            return inspector;
        } catch (Exception e) {
            throw new RuntimeException("Error saving inspector", e);
        }
        */
    }

    /**
     * Delete inspector
     *
     * IN-MEMORY IMPLEMENTATION (Phase 9)
     * For DynamoDB: Use inspectorTable.deleteItem() with partition key
     */
    public void delete(String inspectorId) {
        inspectorStore.remove(inspectorId);

        /* DYNAMODB IMPLEMENTATION (PHASE 10 - UNCOMMENT THIS):
        try {
            Key key = Key.builder()
                    .partitionValue("INSPECTOR#" + inspectorId)
                    .sortValue("METADATA")
                    .build();

            inspectorTable.deleteItem(key);
        } catch (Exception e) {
            throw new RuntimeException("Error deleting inspector: " + inspectorId, e);
        }
        */
    }

    // ========================================
    // ADDITIONAL METHODS FOR IN-MEMORY TESTING
    // ========================================
    // REMOVE THESE FOR PRODUCTION (PHASE 10)

    /**
     * Get all inspectors (for testing only)
     * NOT NEEDED FOR DYNAMODB
     */
    public Map<String, Inspector> getAllInspectors() {
        return inspectorStore;
    }

    /**
     * Clear all inspectors (for testing only)
     * NOT NEEDED FOR DYNAMODB
     */
    public void clearAll() {
        inspectorStore.clear();
    }
}
