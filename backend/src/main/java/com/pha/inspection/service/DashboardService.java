package com.pha.inspection.service;

import com.pha.inspection.model.dto.DashboardFilterDTO;
import com.pha.inspection.model.dto.DashboardSummaryDTO;
import com.pha.inspection.model.dto.SiteSummaryDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Dashboard Service
 * Handles dashboard filtering and aggregation logic
 */
@Service
public class DashboardService {

    private static final Logger logger = LoggerFactory.getLogger(DashboardService.class);

    // Mock data for Phase 3 testing (will be replaced with DynamoDB queries in later phases)
    private List<SiteSummaryDTO> mockData;

    public DashboardService() {
        initializeMockData();
    }

    /**
     * Get dashboard summary with filters
     */
    public DashboardSummaryDTO getDashboardSummary(DashboardFilterDTO filters) {
        logger.info("Getting dashboard summary with filters: area={}, year={}, month={}, siteCode={}",
                filters.getArea(), filters.getYear(), filters.getMonth(), filters.getSiteCode());

        // Filter mock data based on filters
        List<SiteSummaryDTO> filteredSites = filterSites(filters);

        // Create and return summary
        return new DashboardSummaryDTO(filters, filteredSites);
    }

    /**
     * Filter sites based on dashboard filters
     */
    private List<SiteSummaryDTO> filterSites(DashboardFilterDTO filters) {
        List<SiteSummaryDTO> result = new ArrayList<>(mockData);

        // Filter by siteCode if provided
        if (filters.getSiteCode() != null && !filters.getSiteCode().isEmpty()) {
            result = result.stream()
                    .filter(site -> site.getSiteCode().equals(filters.getSiteCode()))
                    .collect(Collectors.toList());
        }

        // Note: In real implementation, area/year/month filtering would query DynamoDB
        // with appropriate GSI indexes. For Phase 3, we're returning all mock data.

        return result;
    }

    /**
     * Initialize mock data for testing
     * Simulates inspection data for different sites
     */
    private void initializeMockData() {
        mockData = new ArrayList<>();

        // Scattered Sites (SS)
        mockData.add(new SiteSummaryDTO("901", "Haddington", 5, 3, 12));
        mockData.add(new SiteSummaryDTO("902", "Mantua", 8, 2, 15));
        mockData.add(new SiteSummaryDTO("903", "Strawberry Mansion", 3, 5, 10));
        mockData.add(new SiteSummaryDTO("904", "Fairhill", 6, 4, 8));

        // Conventional Sites (CS)
        mockData.add(new SiteSummaryDTO("801", "Queen Lane", 4, 6, 20));
        mockData.add(new SiteSummaryDTO("802", "Spring Garden", 7, 3, 18));
        mockData.add(new SiteSummaryDTO("803", "Westpark", 2, 8, 14));

        // AMPB Sites
        mockData.add(new SiteSummaryDTO("701", "Martin Luther King", 10, 5, 25));
        mockData.add(new SiteSummaryDTO("702", "Richard Allen", 6, 7, 22));

        // PAPMC Sites
        mockData.add(new SiteSummaryDTO("601", "Wilson Park", 5, 4, 16));
        mockData.add(new SiteSummaryDTO("602", "Paschall", 3, 6, 19));

        logger.info("Initialized {} mock sites for dashboard testing", mockData.size());
    }

    /**
     * Get all sites (for testing)
     */
    public List<SiteSummaryDTO> getAllSites() {
        return new ArrayList<>(mockData);
    }
}
