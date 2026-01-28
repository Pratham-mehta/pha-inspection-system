package com.pha.inspection.repository;

import com.pha.inspection.model.entity.Inspection;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

/**
 * In-memory implementation of InspectionRepository
 * For Phase 4 testing - will be replaced with DynamoDB implementation
 */
@Component
public class InspectionRepositoryImpl implements InspectionRepository {

    private final Map<String, Inspection> inMemoryStore = new HashMap<>();

    @Override
    public Inspection save(Inspection inspection) {
        inMemoryStore.put(inspection.getSoNumber(), inspection);
        return inspection;
    }

    @Override
    public Optional<Inspection> findBySoNumber(String soNumber) {
        return Optional.ofNullable(inMemoryStore.get(soNumber));
    }

    @Override
    public List<Inspection> findAll() {
        return new ArrayList<>(inMemoryStore.values());
    }

    @Override
    public List<Inspection> findByStatus(String status) {
        return inMemoryStore.values().stream()
                .filter(inspection -> status.equals(inspection.getStatus()))
                .collect(Collectors.toList());
    }

    @Override
    public List<Inspection> findBySiteCode(String siteCode) {
        return inMemoryStore.values().stream()
                .filter(inspection -> siteCode.equals(inspection.getSiteCode()))
                .collect(Collectors.toList());
    }

    @Override
    public List<Inspection> findByInspectorId(String inspectorId) {
        return inMemoryStore.values().stream()
                .filter(inspection -> inspectorId.equals(inspection.getInspectorId()))
                .collect(Collectors.toList());
    }

    @Override
    public void deleteBySoNumber(String soNumber) {
        inMemoryStore.remove(soNumber);
    }

    @Override
    public long count() {
        return inMemoryStore.size();
    }
}
