package com.pha.inspection.controller;

import com.pha.inspection.model.dto.AreaDTO;
import com.pha.inspection.model.dto.ItemDTO;
import com.pha.inspection.service.AreaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Area Controller
 * Handles inspection area and item endpoints
 */
@RestController
@RequestMapping("/inspections/areas")
@Tag(name = "Inspection Areas", description = "Inspection checklist areas and items")
@SecurityRequirement(name = "Bearer Authentication")
public class AreaController {

    private static final Logger logger = LoggerFactory.getLogger(AreaController.class);

    @Autowired
    private AreaService areaService;

    /**
     * Get all inspection areas
     */
    @GetMapping
    @Operation(
            summary = "Get all inspection areas",
            description = "List all inspection areas sorted by sortOrder"
    )
    public ResponseEntity<List<AreaDTO>> getAllAreas() {
        logger.info("GET /inspections/areas");

        List<AreaDTO> areas = areaService.getAllAreas();
        return ResponseEntity.ok(areas);
    }

    /**
     * Get items for specific area
     */
    @GetMapping("/items")
    @Operation(
            summary = "Get inspection items by area",
            description = "List all inspection items for a specific area sorted by sortOrder"
    )
    public ResponseEntity<List<ItemDTO>> getItemsByArea(@RequestParam String areaName) {
        logger.info("GET /inspections/areas/items?areaName={}", areaName);

        List<ItemDTO> items = areaService.getItemsByArea(areaName);
        return ResponseEntity.ok(items);
    }
}
