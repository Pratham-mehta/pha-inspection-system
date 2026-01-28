package com.pha.inspection.service;

import com.pha.inspection.model.dto.PMICategoryDTO;
import com.pha.inspection.model.dto.PMIItemDTO;
import com.pha.inspection.model.entity.PMICategory;
import com.pha.inspection.model.entity.PMIItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * PMI Service
 * Handles PMI (Preventive Maintenance Inspection) category and item management
 */
@Service
public class PMIService {

    private static final Logger logger = LoggerFactory.getLogger(PMIService.class);

    // In-memory storage
    private final List<PMICategory> categories = new ArrayList<>();
    private final Map<String, List<PMIItem>> itemsByCategory = new HashMap<>();

    public PMIService() {
        initializeMockData();
    }

    /**
     * Get all PMI categories
     */
    public List<PMICategoryDTO> getAllCategories() {
        logger.info("Getting all PMI categories");

        return categories.stream()
                .filter(PMICategory::getIsActive)
                .sorted(Comparator.comparing(PMICategory::getSortOrder))
                .map(this::convertCategoryToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get all items for a category
     */
    public List<PMIItemDTO> getItemsByCategory(String categoryId) {
        logger.info("Getting PMI items for category: {}", categoryId);

        List<PMIItem> items = itemsByCategory.get(categoryId);
        if (items == null) {
            return new ArrayList<>();
        }

        return items.stream()
                .filter(PMIItem::getIsActive)
                .sorted(Comparator.comparing(PMIItem::getSortOrder))
                .map(this::convertItemToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Initialize mock PMI data
     */
    private void initializeMockData() {
        logger.info("Initializing PMI mock data");

        String timestamp = Instant.now().toString();

        // 1. HVAC
        createCategory("CAT001", "HVAC", 1, timestamp);
        createItem("CAT001", "PMI001", "Replace or clean air filter", 1, timestamp);
        createItem("CAT001", "PMI002", "Check thermostat operation", 2, timestamp);
        createItem("CAT001", "PMI003", "Inspect ductwork for leaks", 3, timestamp);
        createItem("CAT001", "PMI004", "Clean condenser coils", 4, timestamp);

        // 2. Hot Water Tank
        createCategory("CAT002", "Hot Water Tank", 2, timestamp);
        createItem("CAT002", "PMI005", "Drain sediment from tank", 1, timestamp);
        createItem("CAT002", "PMI006", "Check temperature setting (120°F)", 2, timestamp);
        createItem("CAT002", "PMI007", "Inspect for leaks", 3, timestamp);
        createItem("CAT002", "PMI008", "Test pressure relief valve", 4, timestamp);

        // 3. Plumbing
        createCategory("CAT003", "Plumbing", 3, timestamp);
        createItem("CAT003", "PMI009", "Check all faucets for leaks", 1, timestamp);
        createItem("CAT003", "PMI010", "Inspect under sinks for leaks", 2, timestamp);
        createItem("CAT003", "PMI011", "Test toilet flush mechanism", 3, timestamp);
        createItem("CAT003", "PMI012", "Check water pressure", 4, timestamp);

        // 4. Electrical
        createCategory("CAT004", "Electrical", 4, timestamp);
        createItem("CAT004", "PMI013", "Test GFCI outlets", 1, timestamp);
        createItem("CAT004", "PMI014", "Check circuit breaker panel", 2, timestamp);
        createItem("CAT004", "PMI015", "Inspect visible wiring", 3, timestamp);
        createItem("CAT004", "PMI016", "Test smoke detectors", 4, timestamp);

        // 5. Appliances
        createCategory("CAT005", "Appliances", 5, timestamp);
        createItem("CAT005", "PMI017", "Clean refrigerator coils", 1, timestamp);
        createItem("CAT005", "PMI018", "Check stove burners/elements", 2, timestamp);
        createItem("CAT005", "PMI019", "Clean range hood filter", 3, timestamp);
        createItem("CAT005", "PMI020", "Test dishwasher operation", 4, timestamp);

        // 6. Safety Systems
        createCategory("CAT006", "Safety Systems", 6, timestamp);
        createItem("CAT006", "PMI021", "Test smoke detectors (all locations)", 1, timestamp);
        createItem("CAT006", "PMI022", "Test carbon monoxide detectors", 2, timestamp);
        createItem("CAT006", "PMI023", "Check fire extinguisher (if provided)", 3, timestamp);
        createItem("CAT006", "PMI024", "Inspect emergency exits", 4, timestamp);

        // 7. Windows and Doors
        createCategory("CAT007", "Windows and Doors", 7, timestamp);
        createItem("CAT007", "PMI025", "Check window locks", 1, timestamp);
        createItem("CAT007", "PMI026", "Inspect window screens", 2, timestamp);
        createItem("CAT007", "PMI027", "Test door locks", 3, timestamp);
        createItem("CAT007", "PMI028", "Check weatherstripping", 4, timestamp);

        // 8. General Interior
        createCategory("CAT008", "General Interior", 8, timestamp);
        createItem("CAT008", "PMI029", "Check caulking around tubs/showers", 1, timestamp);
        createItem("CAT008", "PMI030", "Inspect for water stains on ceilings", 2, timestamp);
        createItem("CAT008", "PMI031", "Check flooring for damage", 3, timestamp);
        createItem("CAT008", "PMI032", "Test all light fixtures", 4, timestamp);

        logger.info("PMI mock data initialized - {} categories, {} total items",
                categories.size(), itemsByCategory.values().stream().mapToInt(List::size).sum());
    }

    /**
     * Create PMI category
     */
    private void createCategory(String categoryId, String name, Integer sortOrder, String timestamp) {
        PMICategory category = new PMICategory(categoryId, name, sortOrder);
        category.setCreatedAt(timestamp);
        categories.add(category);
    }

    /**
     * Create PMI item
     */
    private void createItem(String categoryId, String itemId, String description, Integer sortOrder, String timestamp) {
        PMIItem item = new PMIItem(categoryId, itemId, description, sortOrder);
        item.setCreatedAt(timestamp);

        itemsByCategory.computeIfAbsent(categoryId, k -> new ArrayList<>()).add(item);
    }

    /**
     * Convert category entity to DTO
     */
    private PMICategoryDTO convertCategoryToDTO(PMICategory category) {
        PMICategoryDTO dto = new PMICategoryDTO();
        dto.setCategoryId(category.getCategoryId());
        dto.setName(category.getName());
        dto.setSortOrder(category.getSortOrder());
        dto.setIsActive(category.getIsActive());
        return dto;
    }

    /**
     * Convert item entity to DTO
     */
    private PMIItemDTO convertItemToDTO(PMIItem item) {
        PMIItemDTO dto = new PMIItemDTO();
        dto.setItemId(item.getItemId());
        dto.setCategoryId(item.getCategoryId());
        dto.setDescription(item.getDescription());
        dto.setSortOrder(item.getSortOrder());
        dto.setIsActive(item.getIsActive());
        return dto;
    }
}
