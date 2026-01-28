package com.pha.inspection.model.dto;

/**
 * DTO for dashboard filter parameters
 */
public class DashboardFilterDTO {

    private String area;        // SS, CS, AMPB, PAPMC
    private Integer year;       // 2004-2025
    private Integer month;      // 1-12
    private String siteCode;    // Optional - filter by specific site

    public DashboardFilterDTO() {
    }

    public DashboardFilterDTO(String area, Integer year, Integer month, String siteCode) {
        this.area = area;
        this.year = year;
        this.month = month;
        this.siteCode = siteCode;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public String getSiteCode() {
        return siteCode;
    }

    public void setSiteCode(String siteCode) {
        this.siteCode = siteCode;
    }
}
