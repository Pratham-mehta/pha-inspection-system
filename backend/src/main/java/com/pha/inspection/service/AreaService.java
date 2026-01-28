package com.pha.inspection.service;

import com.pha.inspection.model.dto.AreaDTO;
import com.pha.inspection.model.dto.ItemDTO;
import com.pha.inspection.model.entity.InspectionArea;
import com.pha.inspection.model.entity.InspectionItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Area Service
 * Handles inspection areas and items
 */
@Service
public class AreaService {

    private static final Logger logger = LoggerFactory.getLogger(AreaService.class);

    // In-memory storage for Phase 5
    private final Map<String, InspectionArea> areas = new LinkedHashMap<>();
    private final Map<String, List<InspectionItem>> itemsByArea = new LinkedHashMap<>();

    public AreaService() {
        initializeMockData();
    }

    /**
     * Get all inspection areas
     */
    public List<AreaDTO> getAllAreas() {
        logger.info("Getting all inspection areas");
        return areas.values().stream()
                .sorted(Comparator.comparing(InspectionArea::getSortOrder))
                .map(this::convertToAreaDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get items for specific area
     */
    public List<ItemDTO> getItemsByArea(String areaName) {
        logger.info("Getting items for area: {}", areaName);

        List<InspectionItem> items = itemsByArea.get(areaName);
        if (items == null) {
            return new ArrayList<>();
        }

        return items.stream()
                .sorted(Comparator.comparing(InspectionItem::getSortOrder))
                .map(this::convertToItemDTO)
                .collect(Collectors.toList());
    }

    private AreaDTO convertToAreaDTO(InspectionArea area) {
        return new AreaDTO(area.getAreaName(), area.getSortOrder(), area.getIsActive());
    }

    private ItemDTO convertToItemDTO(InspectionItem item) {
        return new ItemDTO(item.getItemId(), item.getDescription(), item.getSortOrder(), item.getIsActive());
    }

    /**
     * Initialize comprehensive mock data for inspection checklist
     */
    private void initializeMockData() {
        logger.info("Initializing inspection areas and items mock data");

        // 1. Site and Building Exterior
        createArea("Site and Building Exterior", 1);
        createItem("Site and Building Exterior", "SB001", "Walks, steps, drives - cracks, breaks, trip hazards", 1);
        createItem("Site and Building Exterior", "SB002", "Parking/carport - structural defects, damage", 2);
        createItem("Site and Building Exterior", "SB003", "Fence/retaining wall - structural defects", 3);
        createItem("Site and Building Exterior", "SB004", "Building exterior - foundation cracks, structure issues", 4);
        createItem("Site and Building Exterior", "SB005", "Roof - leaks, damage, missing shingles", 5);
        createItem("Site and Building Exterior", "SB006", "Gutters/downspouts - damage, clogs, detachment", 6);
        createItem("Site and Building Exterior", "SB007", "Windows/screens - broken, damage, missing", 7);
        createItem("Site and Building Exterior", "SB008", "Doors/locks - damage, inoperable, missing", 8);
        createItem("Site and Building Exterior", "SB009", "Paint/siding - peeling, damage, deterioration", 9);

        // 2. Kitchen
        createArea("Kitchen", 2);
        createItem("Kitchen", "K001", "Kitchen sink - leaks, damage", 1);
        createItem("Kitchen", "K002", "Kitchen countertop - cracks, damage", 2);
        createItem("Kitchen", "K003", "Kitchen cabinets - damage, missing, inoperable", 3);
        createItem("Kitchen", "K004", "Kitchen stove - inoperable, gas leaks", 4);
        createItem("Kitchen", "K005", "Kitchen refrigerator - inoperable, damage", 5);
        createItem("Kitchen", "K006", "Kitchen floor - damage, tripping hazard", 6);
        createItem("Kitchen", "K007", "Kitchen walls/ceiling - damage, water stains", 7);
        createItem("Kitchen", "K008", "Kitchen electrical - missing covers, exposed wires", 8);

        // 3. Bathroom
        createArea("Bathroom", 3);
        createItem("Bathroom", "B001", "Bathroom sink - leaks, damage", 1);
        createItem("Bathroom", "B002", "Bathroom toilet - leaks, inoperable, damage", 2);
        createItem("Bathroom", "B003", "Bathroom tub/shower - leaks, damage, missing fixtures", 3);
        createItem("Bathroom", "B004", "Bathroom floor - damage, water damage", 4);
        createItem("Bathroom", "B005", "Bathroom walls/ceiling - damage, water stains, mold", 5);
        createItem("Bathroom", "B006", "Bathroom exhaust fan - inoperable, missing", 6);
        createItem("Bathroom", "B007", "Bathroom electrical - missing covers, GFI issues", 7);
        createItem("Bathroom", "B008", "Bathroom cabinets/vanity - damage, missing", 8);

        // 4. Living Room/Dining Room
        createArea("Living Room/Dining Room", 4);
        createItem("Living Room/Dining Room", "LR001", "Living room floor - damage, tripping hazard", 1);
        createItem("Living Room/Dining Room", "LR002", "Living room walls/ceiling - damage, holes, cracks", 2);
        createItem("Living Room/Dining Room", "LR003", "Living room windows - damage, inoperable", 3);
        createItem("Living Room/Dining Room", "LR004", "Living room electrical - missing covers, outlets inoperable", 4);
        createItem("Living Room/Dining Room", "LR005", "Living room doors - damage, inoperable locks", 5);

        // 5. Bedrooms
        createArea("Bedrooms", 5);
        createItem("Bedrooms", "BR001", "Bedroom floor - damage, tripping hazard", 1);
        createItem("Bedrooms", "BR002", "Bedroom walls/ceiling - damage, holes, cracks", 2);
        createItem("Bedrooms", "BR003", "Bedroom windows - damage, inoperable", 3);
        createItem("Bedrooms", "BR004", "Bedroom closet - damage, missing doors", 4);
        createItem("Bedrooms", "BR005", "Bedroom electrical - missing covers, outlets inoperable", 5);
        createItem("Bedrooms", "BR006", "Bedroom doors - damage, inoperable locks", 6);

        // 6. HVAC/Utilities
        createArea("HVAC/Utilities", 6);
        createItem("HVAC/Utilities", "HV001", "Heating system - inoperable, unsafe", 1);
        createItem("HVAC/Utilities", "HV002", "Air conditioning - inoperable", 2);
        createItem("HVAC/Utilities", "HV003", "Hot water heater - inoperable, leaks", 3);
        createItem("HVAC/Utilities", "HV004", "Thermostat - inoperable, missing", 4);
        createItem("HVAC/Utilities", "HV005", "Ventilation - inadequate, inoperable", 5);
        createItem("HVAC/Utilities", "HV006", "Electrical panel - hazards, improper wiring", 6);
        createItem("HVAC/Utilities", "HV007", "Plumbing - leaks, water pressure issues", 7);

        // 7. Safety/Fire Protection
        createArea("Safety/Fire Protection", 7);
        createItem("Safety/Fire Protection", "SF001", "Smoke detectors - missing, inoperable, expired", 1);
        createItem("Safety/Fire Protection", "SF002", "Carbon monoxide detectors - missing, inoperable, expired", 2);
        createItem("Safety/Fire Protection", "SF003", "Fire extinguisher - missing, expired", 3);
        createItem("Safety/Fire Protection", "SF004", "Emergency exits - blocked, inoperable", 4);
        createItem("Safety/Fire Protection", "SF005", "Railings/guards - missing, damaged, unsafe", 5);

        // 8. Misc/Other
        createArea("Misc/Other", 8);
        createItem("Misc/Other", "M001", "Pest infestation - evidence of rodents, insects", 1);
        createItem("Misc/Other", "M002", "Mold/mildew - visible growth, moisture issues", 2);
        createItem("Misc/Other", "M003", "Lead paint hazards - peeling paint (pre-1978 homes)", 3);
        createItem("Misc/Other", "M004", "Trip hazards - loose carpet, uneven floors", 4);
        createItem("Misc/Other", "M005", "Storage/clutter - excessive, blocking access", 5);
        createItem("Misc/Other", "M006", "Other deficiencies - specify in notes", 6);

        logger.info("Mock data initialized - {} areas, {} total items",
                areas.size(), itemsByArea.values().stream().mapToInt(List::size).sum());
    }

    private void createArea(String areaName, int sortOrder) {
        InspectionArea area = new InspectionArea(areaName, sortOrder);
        areas.put(areaName, area);
        itemsByArea.put(areaName, new ArrayList<>());
    }

    private void createItem(String areaName, String itemId, String description, int sortOrder) {
        InspectionItem item = new InspectionItem(areaName, itemId, description, sortOrder);
        itemsByArea.get(areaName).add(item);
    }
}
