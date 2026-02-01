package com.pha.inspection.service;

import com.pha.inspection.model.dto.DashboardFilterDTO;
import com.pha.inspection.model.dto.DashboardSummaryDTO;
import com.pha.inspection.model.dto.SiteSummaryDTO;
import com.pha.inspection.model.entity.Inspection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbIndex;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryConditional;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryEnhancedRequest;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Dashboard Service - DynamoDB Implementation
 * Handles dashboard filtering and aggregation logic
 */
@Service
public class DashboardService {

    private static final Logger logger = LoggerFactory.getLogger(DashboardService.class);

    private final DynamoDbTable<Inspection> inspectionTable;
    private final DynamoDbIndex<Inspection> gsi2; // STATUS#New/InProgress/Closed → DATE#

    @Autowired
    public DashboardService(DynamoDbEnhancedClient dynamoDbEnhancedClient) {
        this.inspectionTable = dynamoDbEnhancedClient.table("pha-inspections", TableSchema.fromBean(Inspection.class));
        this.gsi2 = inspectionTable.index("GSI2");
        logger.info("DashboardService initialized with DynamoDB table: pha-inspections");
    }

    /**
     * Get dashboard summary with filters
     */
    public DashboardSummaryDTO getDashboardSummary(DashboardFilterDTO filters) {
        logger.info("Getting dashboard summary with filters: area={}, year={}, month={}, siteCode={}",
                filters.getArea(), filters.getYear(), filters.getMonth(), filters.getSiteCode());

        try {
            // Get all inspections (or filtered by status if needed)
            List<Inspection> allInspections = getAllInspections();

            // Apply filters and aggregate by site
            List<SiteSummaryDTO> siteSummaries = aggregateBySite(allInspections, filters);

            logger.info("Dashboard summary generated with {} sites", siteSummaries.size());

            // Create and return summary
            return new DashboardSummaryDTO(filters, siteSummaries);
        } catch (Exception e) {
            logger.error("Error getting dashboard summary", e);
            throw new RuntimeException("Failed to get dashboard summary", e);
        }
    }

    /**
     * Get all inspections from DynamoDB
     */
    private List<Inspection> getAllInspections() {
        List<Inspection> allInspections = new ArrayList<>();

        try {
            // Query GSI2 for all statuses
            String[] statuses = {"New", "InProgress", "Closed"};

            for (String status : statuses) {
                QueryConditional queryConditional = QueryConditional.keyEqualTo(Key.builder()
                        .partitionValue("STATUS#" + status)
                        .build());

                QueryEnhancedRequest queryRequest = QueryEnhancedRequest.builder()
                        .queryConditional(queryConditional)
                        .build();

                List<Inspection> statusInspections = gsi2.query(queryRequest).stream()
                        .flatMap(page -> page.items().stream())
                        .collect(Collectors.toList());

                allInspections.addAll(statusInspections);
                logger.debug("Found {} inspections with status: {}", statusInspections.size(), status);
            }

            logger.info("Total inspections loaded: {}", allInspections.size());
        } catch (Exception e) {
            logger.error("Error loading inspections from DynamoDB", e);
        }

        return allInspections;
    }

    /**
     * Aggregate inspections by site and apply filters
     */
    private List<SiteSummaryDTO> aggregateBySite(List<Inspection> inspections, DashboardFilterDTO filters) {
        // Group by site code
        Map<String, List<Inspection>> inspectionsBySite = inspections.stream()
                .filter(inspection -> {
                    // Filter by siteCode if provided
                    if (filters.getSiteCode() != null && !filters.getSiteCode().isEmpty()) {
                        return inspection.getSiteCode().equals(filters.getSiteCode());
                    }
                    return true;
                })
                // Note: In production, add area/year/month filtering based on inspection dates
                .collect(Collectors.groupingBy(Inspection::getSiteCode));

        // Convert to SiteSummaryDTO list
        List<SiteSummaryDTO> siteSummaries = inspectionsBySite.entrySet().stream()
                .map(entry -> {
                    String siteCode = entry.getKey();
                    List<Inspection> siteInspections = entry.getValue();

                    // Get site name from first inspection (all should have same site name)
                    String siteName = siteInspections.isEmpty() ? "" : siteInspections.get(0).getSiteName();

                    // Count by status
                    long newCount = siteInspections.stream()
                            .filter(i -> "New".equals(i.getStatus()))
                            .count();

                    long inProgressCount = siteInspections.stream()
                            .filter(i -> "InProgress".equals(i.getStatus()))
                            .count();

                    long closedCount = siteInspections.stream()
                            .filter(i -> "Closed".equals(i.getStatus()))
                            .count();

                    return new SiteSummaryDTO(
                            siteCode,
                            siteName,
                            (int) newCount,
                            (int) inProgressCount,
                            (int) closedCount
                    );
                })
                .sorted(Comparator.comparing(SiteSummaryDTO::getSiteCode))
                .collect(Collectors.toList());

        logger.info("Aggregated {} sites from {} inspections", siteSummaries.size(), inspections.size());

        return siteSummaries;
    }

    /**
     * Get all sites (for testing)
     */
    public List<SiteSummaryDTO> getAllSites() {
        DashboardFilterDTO filters = new DashboardFilterDTO();
        return getDashboardSummary(filters).getSites();
    }
}
