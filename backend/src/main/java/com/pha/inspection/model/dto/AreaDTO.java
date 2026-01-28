package com.pha.inspection.model.dto;

/**
 * DTO for Inspection Area API responses
 */
public class AreaDTO {

    private String areaName;
    private Integer sortOrder;
    private Boolean isActive;

    public AreaDTO() {
    }

    public AreaDTO(String areaName, Integer sortOrder, Boolean isActive) {
        this.areaName = areaName;
        this.sortOrder = sortOrder;
        this.isActive = isActive;
    }

    public String getAreaName() {
        return areaName;
    }

    public void setAreaName(String areaName) {
        this.areaName = areaName;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
