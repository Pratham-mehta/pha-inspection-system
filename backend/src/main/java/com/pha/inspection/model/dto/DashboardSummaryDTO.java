package com.pha.inspection.model.dto;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DTO for dashboard summary response
 */
public class DashboardSummaryDTO {

    private DashboardFilterDTO filters;
    private List<SiteSummaryDTO> sites;
    private Map<String, Integer> totals;

    public DashboardSummaryDTO() {
        this.totals = new HashMap<>();
    }

    public DashboardSummaryDTO(DashboardFilterDTO filters, List<SiteSummaryDTO> sites) {
        this.filters = filters;
        this.sites = sites;
        this.totals = calculateTotals(sites);
    }

    public DashboardFilterDTO getFilters() {
        return filters;
    }

    public void setFilters(DashboardFilterDTO filters) {
        this.filters = filters;
    }

    public List<SiteSummaryDTO> getSites() {
        return sites;
    }

    public void setSites(List<SiteSummaryDTO> sites) {
        this.sites = sites;
        this.totals = calculateTotals(sites);
    }

    public Map<String, Integer> getTotals() {
        return totals;
    }

    private Map<String, Integer> calculateTotals(List<SiteSummaryDTO> sites) {
        Map<String, Integer> totals = new HashMap<>();
        int newTotal = 0;
        int inProgressTotal = 0;
        int closedTotal = 0;

        if (sites != null) {
            for (SiteSummaryDTO site : sites) {
                newTotal += site.getNewCount();
                inProgressTotal += site.getInProgressCount();
                closedTotal += site.getClosedCount();
            }
        }

        totals.put("new", newTotal);
        totals.put("inProgress", inProgressTotal);
        totals.put("closed", closedTotal);
        totals.put("total", newTotal + inProgressTotal + closedTotal);

        return totals;
    }
}
