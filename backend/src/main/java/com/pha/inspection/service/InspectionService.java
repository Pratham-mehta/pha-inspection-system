package com.pha.inspection.service;

import com.pha.inspection.model.dto.*;
import com.pha.inspection.model.entity.Inspection;
import com.pha.inspection.repository.InspectionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

/**
 * Inspection Service
 * Handles CRUD operations for inspections
 */
@Service
public class InspectionService {

    private static final Logger logger = LoggerFactory.getLogger(InspectionService.class);

    @Autowired
    private InspectionRepository inspectionRepository;

    // SO number generator (will be replaced with actual logic in production)
    private final AtomicLong soNumberGenerator = new AtomicLong(3184947);

    /**
     * Get all inspections with optional filters and pagination
     */
    public InspectionListDTO getAllInspections(String status, String area, String siteCode, int page, int size) {
        logger.info("Getting inspections - status: {}, area: {}, siteCode: {}, page: {}, size: {}",
                status, area, siteCode, page, size);

        List<Inspection> inspections = inspectionRepository.findAll();

        // Apply filters
        if (status != null && !status.isEmpty()) {
            inspections = inspections.stream()
                    .filter(i -> status.equals(i.getStatus()))
                    .collect(Collectors.toList());
        }

        if (siteCode != null && !siteCode.isEmpty()) {
            inspections = inspections.stream()
                    .filter(i -> siteCode.equals(i.getSiteCode()))
                    .collect(Collectors.toList());
        }

        // Calculate pagination
        int totalElements = inspections.size();
        int startIndex = page * size;
        int endIndex = Math.min(startIndex + size, totalElements);

        // Get page subset
        List<Inspection> pageInspections = inspections.subList(
                Math.min(startIndex, totalElements),
                Math.min(endIndex, totalElements)
        );

        // Convert to DTOs
        List<InspectionSummaryDTO> summaries = pageInspections.stream()
                .map(this::convertToSummaryDTO)
                .collect(Collectors.toList());

        return new InspectionListDTO(summaries, totalElements, page, size);
    }

    /**
     * Get inspection by SO number
     */
    public Optional<InspectionDTO> getInspectionBySoNumber(String soNumber) {
        logger.info("Getting inspection by SO number: {}", soNumber);

        Optional<Inspection> inspection = inspectionRepository.findBySoNumber(soNumber);
        return inspection.map(this::convertToDTO);
    }

    /**
     * Create new inspection
     */
    public String createInspection(CreateInspectionRequest request) {
        logger.info("Creating new inspection for unit: {}", request.getUnitNumber());

        // Generate SO number
        String soNumber = String.valueOf(soNumberGenerator.incrementAndGet());

        // Create inspection entity
        Inspection inspection = new Inspection();
        inspection.setSoNumber(soNumber);
        inspection.setUnitNumber(request.getUnitNumber());
        inspection.setSiteCode(request.getSiteCode());
        inspection.setSiteName(request.getSiteName());
        inspection.setAddress(request.getAddress());
        inspection.setDivisionCode(request.getDivisionCode());

        // Tenant info
        inspection.setTenantName(request.getTenantName());
        inspection.setTenantPhone(request.getTenantPhone());
        inspection.setTenantAvailability(request.getTenantAvailability());

        // Unit info
        inspection.setBrSize(request.getBrSize());
        inspection.setIsHardwired(request.getIsHardwired());

        // Inspector info
        inspection.setInspectorId(request.getInspectorId());
        inspection.setInspectorName(request.getInspectorName());
        inspection.setVehicleTagId(request.getVehicleTagId());

        // Schedule
        inspection.setStartDate(request.getStartDate());
        inspection.setStartTime(request.getStartTime());

        // Initialize GSI keys
        inspection.initializeGSI();

        // Save
        inspectionRepository.save(inspection);

        logger.info("Created inspection with SO number: {}", soNumber);
        return soNumber;
    }

    /**
     * Update inspection
     */
    public boolean updateInspection(String soNumber, UpdateInspectionRequest request) {
        logger.info("Updating inspection: {}", soNumber);

        Optional<Inspection> optInspection = inspectionRepository.findBySoNumber(soNumber);
        if (optInspection.isEmpty()) {
            logger.warn("Inspection not found: {}", soNumber);
            return false;
        }

        Inspection inspection = optInspection.get();

        // Update fields if provided
        if (request.getStatus() != null) {
            inspection.setStatus(request.getStatus());
        }
        if (request.getStartTime() != null) {
            inspection.setStartTime(request.getStartTime());
        }
        if (request.getEndDate() != null) {
            inspection.setEndDate(request.getEndDate());
        }
        if (request.getEndTime() != null) {
            inspection.setEndTime(request.getEndTime());
        }
        if (request.getSubmitTime() != null) {
            inspection.setSubmitTime(request.getSubmitTime());
        }
        if (request.getCompletionDate() != null) {
            inspection.setCompletionDate(request.getCompletionDate());
        }
        if (request.getTenantName() != null) {
            inspection.setTenantName(request.getTenantName());
        }
        if (request.getTenantPhone() != null) {
            inspection.setTenantPhone(request.getTenantPhone());
        }
        if (request.getTenantAvailability() != null) {
            inspection.setTenantAvailability(request.getTenantAvailability());
        }
        if (request.getSmokeDetectorsCount() != null) {
            inspection.setSmokeDetectorsCount(request.getSmokeDetectorsCount());
        }
        if (request.getCoDetectorsCount() != null) {
            inspection.setCoDetectorsCount(request.getCoDetectorsCount());
        }

        // Update timestamp
        inspection.setUpdatedAt(Instant.now().toString());

        // Save
        inspectionRepository.save(inspection);

        logger.info("Updated inspection: {}", soNumber);
        return true;
    }

    /**
     * Submit inspection (close it)
     */
    public boolean submitInspection(String soNumber, UpdateInspectionRequest request) {
        logger.info("Submitting inspection: {}", soNumber);

        Optional<Inspection> optInspection = inspectionRepository.findBySoNumber(soNumber);
        if (optInspection.isEmpty()) {
            logger.warn("Inspection not found: {}", soNumber);
            return false;
        }

        Inspection inspection = optInspection.get();

        // Set status to Closed
        inspection.setStatus("Closed");

        // Update end time and completion date if provided
        if (request.getEndTime() != null) {
            inspection.setEndTime(request.getEndTime());
        }
        if (request.getCompletionDate() != null) {
            inspection.setCompletionDate(request.getCompletionDate());
        }

        // Set submit time
        inspection.setSubmitTime(Instant.now().toString());
        inspection.setUpdatedAt(Instant.now().toString());

        // Save
        inspectionRepository.save(inspection);

        logger.info("Submitted inspection: {}", soNumber);
        return true;
    }

    /**
     * Convert Inspection entity to InspectionDTO
     */
    private InspectionDTO convertToDTO(Inspection inspection) {
        InspectionDTO dto = new InspectionDTO();
        dto.setSoNumber(inspection.getSoNumber());
        dto.setUnitNumber(inspection.getUnitNumber());
        dto.setSiteCode(inspection.getSiteCode());
        dto.setSiteName(inspection.getSiteName());
        dto.setAddress(inspection.getAddress());
        dto.setDivisionCode(inspection.getDivisionCode());
        dto.setTenantName(inspection.getTenantName());
        dto.setTenantPhone(inspection.getTenantPhone());
        dto.setTenantAvailability(inspection.getTenantAvailability());
        dto.setBrSize(inspection.getBrSize());
        dto.setIsHardwired(inspection.getIsHardwired());
        dto.setInspectorId(inspection.getInspectorId());
        dto.setInspectorName(inspection.getInspectorName());
        dto.setVehicleTagId(inspection.getVehicleTagId());
        dto.setStatus(inspection.getStatus());
        dto.setStartDate(inspection.getStartDate());
        dto.setStartTime(inspection.getStartTime());
        dto.setEndDate(inspection.getEndDate());
        dto.setEndTime(inspection.getEndTime());
        dto.setSubmitTime(inspection.getSubmitTime());
        dto.setCompletionDate(inspection.getCompletionDate());
        dto.setSmokeDetectorsCount(inspection.getSmokeDetectorsCount());
        dto.setCoDetectorsCount(inspection.getCoDetectorsCount());
        dto.setCreatedAt(inspection.getCreatedAt());
        dto.setUpdatedAt(inspection.getUpdatedAt());
        return dto;
    }

    /**
     * Convert Inspection entity to InspectionSummaryDTO
     */
    private InspectionSummaryDTO convertToSummaryDTO(Inspection inspection) {
        return new InspectionSummaryDTO(
                inspection.getSoNumber(),
                inspection.getUnitNumber(),
                inspection.getStartDate(),
                inspection.getDivisionCode(),
                inspection.getSiteCode(),
                inspection.getSiteName(),
                inspection.getTenantName(),
                inspection.getAddress(),
                inspection.getCompletionDate(),
                inspection.getStatus()
        );
    }

    /**
     * Initialize mock data for testing
     */
    public void initializeMockData() {
        logger.info("Initializing mock inspection data");

        // Create 15 mock inspections across different sites and statuses
        createMockInspection("041529", "901", "Haddington", "123 Main St, Unit 041529", "D1", "INS001", "CASTOR_USER5", "Q", "New", "2025-05-02");
        createMockInspection("041530", "901", "Haddington", "125 Main St, Unit 041530", "D1", "INS001", "CASTOR_USER5", "Q", "New", "2025-05-02");
        createMockInspection("041531", "901", "Haddington", "127 Main St, Unit 041531", "D1", "INS002", "CASTOR_USER6", "R", "InProgress", "2025-05-01");

        createMockInspection("042001", "902", "Mantua", "200 Oak St, Unit 042001", "D1", "INS001", "CASTOR_USER5", "Q", "New", "2025-05-03");
        createMockInspection("042002", "902", "Mantua", "202 Oak St, Unit 042002", "D1", "INS002", "CASTOR_USER6", "R", "Closed", "2025-04-28");

        createMockInspection("050001", "903", "Strawberry Mansion", "300 Pine St, Unit 050001", "D2", "INS001", "CASTOR_USER5", "Q", "New", "2025-05-04");
        createMockInspection("050002", "903", "Strawberry Mansion", "302 Pine St, Unit 050002", "D2", "INS003", "CASTOR_USER7", "S", "InProgress", "2025-05-02");
        createMockInspection("050003", "903", "Strawberry Mansion", "304 Pine St, Unit 050003", "D2", "INS003", "CASTOR_USER7", "S", "Closed", "2025-04-25");

        createMockInspection("060001", "801", "Queen Lane", "400 Elm St, Unit 060001", "D3", "INS002", "CASTOR_USER6", "R", "New", "2025-05-05");
        createMockInspection("060002", "801", "Queen Lane", "402 Elm St, Unit 060002", "D3", "INS002", "CASTOR_USER6", "R", "InProgress", "2025-05-03");
        createMockInspection("060003", "801", "Queen Lane", "404 Elm St, Unit 060003", "D3", "INS001", "CASTOR_USER5", "Q", "Closed", "2025-04-20");

        createMockInspection("070001", "701", "Martin Luther King", "500 Maple St, Unit 070001", "D4", "INS003", "CASTOR_USER7", "S", "New", "2025-05-06");
        createMockInspection("070002", "701", "Martin Luther King", "502 Maple St, Unit 070002", "D4", "INS003", "CASTOR_USER7", "S", "InProgress", "2025-05-04");
        createMockInspection("070003", "701", "Martin Luther King", "504 Maple St, Unit 070003", "D4", "INS002", "CASTOR_USER6", "R", "Closed", "2025-04-18");
        createMockInspection("070004", "701", "Martin Luther King", "506 Maple St, Unit 070004", "D4", "INS001", "CASTOR_USER5", "Q", "Closed", "2025-04-15");

        logger.info("Mock data initialized - {} inspections created", inspectionRepository.count());
    }

    private void createMockInspection(String unitNumber, String siteCode, String siteName, String address,
                                      String divisionCode, String inspectorId, String inspectorName,
                                      String vehicleTagId, String status, String startDate) {
        String soNumber = String.valueOf(soNumberGenerator.incrementAndGet());

        Inspection inspection = new Inspection();
        inspection.setSoNumber(soNumber);
        inspection.setUnitNumber(unitNumber);
        inspection.setSiteCode(siteCode);
        inspection.setSiteName(siteName);
        inspection.setAddress(address);
        inspection.setDivisionCode(divisionCode);
        inspection.setTenantName("Tenant " + unitNumber);
        inspection.setTenantPhone("+1215555" + unitNumber.substring(unitNumber.length() - 4));
        inspection.setTenantAvailability(true);
        inspection.setBrSize(2);
        inspection.setIsHardwired(false);
        inspection.setInspectorId(inspectorId);
        inspection.setInspectorName(inspectorName);
        inspection.setVehicleTagId(vehicleTagId);
        inspection.setStatus(status);
        inspection.setStartDate(startDate);
        inspection.setStartTime("08:30:00");

        if ("Closed".equals(status)) {
            inspection.setEndDate(startDate);
            inspection.setEndTime("09:30:00");
            inspection.setCompletionDate(startDate);
            inspection.setSubmitTime(Instant.now().toString());
            inspection.setSmokeDetectorsCount(5);
            inspection.setCoDetectorsCount(3);
        } else if ("InProgress".equals(status)) {
            inspection.setSmokeDetectorsCount(5);
            inspection.setCoDetectorsCount(3);
        }

        inspection.initializeGSI();
        inspectionRepository.save(inspection);
    }
}
