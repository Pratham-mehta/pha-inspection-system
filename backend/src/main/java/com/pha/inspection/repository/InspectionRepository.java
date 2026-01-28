package com.pha.inspection.repository;

import com.pha.inspection.model.entity.Inspection;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Inspection entity
 * For Phase 4, uses in-memory storage
 * Will be replaced with DynamoDB implementation in later phases
 */
@Repository
public interface InspectionRepository {

    /**
     * Save or update an inspection
     */
    Inspection save(Inspection inspection);

    /**
     * Find inspection by SO number
     */
    Optional<Inspection> findBySoNumber(String soNumber);

    /**
     * Find all inspections
     */
    List<Inspection> findAll();

    /**
     * Find inspections by status
     */
    List<Inspection> findByStatus(String status);

    /**
     * Find inspections by site code
     */
    List<Inspection> findBySiteCode(String siteCode);

    /**
     * Find inspections by inspector ID
     */
    List<Inspection> findByInspectorId(String inspectorId);

    /**
     * Delete inspection by SO number
     */
    void deleteBySoNumber(String soNumber);

    /**
     * Count all inspections
     */
    long count();
}
