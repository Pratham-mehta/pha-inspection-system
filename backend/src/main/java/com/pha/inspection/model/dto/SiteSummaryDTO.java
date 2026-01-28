package com.pha.inspection.model.dto;

/**
 * DTO for site-level inspection statistics
 */
public class SiteSummaryDTO {

    private String siteCode;
    private String siteName;
    private int newCount;
    private int inProgressCount;
    private int closedCount;
    private int totalCount;

    public SiteSummaryDTO() {
    }

    public SiteSummaryDTO(String siteCode, String siteName, int newCount, int inProgressCount, int closedCount) {
        this.siteCode = siteCode;
        this.siteName = siteName;
        this.newCount = newCount;
        this.inProgressCount = inProgressCount;
        this.closedCount = closedCount;
        this.totalCount = newCount + inProgressCount + closedCount;
    }

    public String getSiteCode() {
        return siteCode;
    }

    public void setSiteCode(String siteCode) {
        this.siteCode = siteCode;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public int getNewCount() {
        return newCount;
    }

    public void setNewCount(int newCount) {
        this.newCount = newCount;
        updateTotal();
    }

    public int getInProgressCount() {
        return inProgressCount;
    }

    public void setInProgressCount(int inProgressCount) {
        this.inProgressCount = inProgressCount;
        updateTotal();
    }

    public int getClosedCount() {
        return closedCount;
    }

    public void setClosedCount(int closedCount) {
        this.closedCount = closedCount;
        updateTotal();
    }

    public int getTotalCount() {
        return totalCount;
    }

    private void updateTotal() {
        this.totalCount = this.newCount + this.inProgressCount + this.closedCount;
    }
}
