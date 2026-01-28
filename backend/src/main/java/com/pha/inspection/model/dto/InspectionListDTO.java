package com.pha.inspection.model.dto;

import java.util.List;

/**
 * DTO for paginated inspection list responses
 */
public class InspectionListDTO {

    private List<InspectionSummaryDTO> content;
    private int totalElements;
    private int totalPages;
    private int currentPage;
    private int pageSize;

    public InspectionListDTO() {
    }

    public InspectionListDTO(List<InspectionSummaryDTO> content, int totalElements, int currentPage, int pageSize) {
        this.content = content;
        this.totalElements = totalElements;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalPages = (int) Math.ceil((double) totalElements / pageSize);
    }

    public List<InspectionSummaryDTO> getContent() {
        return content;
    }

    public void setContent(List<InspectionSummaryDTO> content) {
        this.content = content;
    }

    public int getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(int totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }
}
