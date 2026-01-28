package com.pha.inspection.controller;

import com.pha.inspection.model.dto.DashboardFilterDTO;
import com.pha.inspection.model.dto.DashboardSummaryDTO;
import com.pha.inspection.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Dashboard Controller
 * Handles dashboard filtering and summary endpoints
 */
@RestController
@RequestMapping("/dashboard")
@Tag(name = "Dashboard", description = "Dashboard filtering and summary endpoints")
@SecurityRequirement(name = "Bearer Authentication")
public class DashboardController {

    private static final Logger logger = LoggerFactory.getLogger(DashboardController.class);

    @Autowired
    private DashboardService dashboardService;

    /**
     * Get dashboard summary with filters
     */
    @GetMapping("/summary")
    @Operation(
            summary = "Get dashboard summary",
            description = "Get inspection statistics grouped by site with optional filters (area, year, month, site)"
    )
    public ResponseEntity<DashboardSummaryDTO> getDashboardSummary(
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) String siteCode) {

        logger.info("Dashboard summary requested - area: {}, year: {}, month: {}, siteCode: {}",
                area, year, month, siteCode);

        // Create filter DTO
        DashboardFilterDTO filters = new DashboardFilterDTO(area, year, month, siteCode);

        // Get summary from service
        DashboardSummaryDTO summary = dashboardService.getDashboardSummary(filters);

        return ResponseEntity.ok(summary);
    }
}
