//
//  Inspection.swift
//  PHA Inspection App
//
//  Model for Inspection entity
//

import Foundation

// MARK: - Inspection Detail
struct Inspection: Codable, Identifiable {
    let id: String
    let unitNumber: String
    let siteCode: String
    let address: String
    let tenantName: String?
    let tenantPhone: String?
    let tenantAvailability: Bool?
    let brSize: Int?
    let isHardwired: Bool?
    let status: InspectionStatus
    let inspectorName: String?
    let vehicleTagId: String?
    let startDate: String?
    let startTime: String?
    let endDate: String?
    let endTime: String?
    let submitTime: String?
    let smokeDetectorsCount: Int?
    let coDetectorsCount: Int?
    let completionDate: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "soNumber"
        case unitNumber
        case siteCode
        case address
        case tenantName
        case tenantPhone
        case tenantAvailability
        case brSize
        case isHardwired
        case status
        case inspectorName
        case vehicleTagId
        case startDate
        case startTime
        case endDate
        case endTime
        case submitTime
        case smokeDetectorsCount
        case coDetectorsCount
        case completionDate
        case createdAt
        case updatedAt
    }
}

// MARK: - Inspection Summary (for list views)
struct InspectionSummary: Codable, Identifiable {
    let id: String
    let unitNumber: String
    let soDate: String
    let divisionCode: String
    let siteCode: String
    let siteName: String
    let tenantName: String?
    let address: String
    let completionDate: String?
    let status: InspectionStatus

    enum CodingKeys: String, CodingKey {
        case id = "soNumber"
        case unitNumber
        case soDate
        case divisionCode
        case siteCode
        case siteName
        case tenantName
        case address
        case completionDate
        case status
    }
}

// MARK: - Inspection List Response
struct InspectionListResponse: Codable {
    let content: [InspectionSummary]
    let totalElements: Int
    let totalPages: Int
    let currentPage: Int
}

// MARK: - Inspection Status Enum
enum InspectionStatus: String, Codable, CaseIterable {
    case new = "New"
    case inProgress = "InProgress"
    case closed = "Closed"

    var displayName: String {
        switch self {
        case .new: return "New"
        case .inProgress: return "In Progress"
        case .closed: return "Closed"
        }
    }

    var color: String {
        switch self {
        case .new: return "blue"
        case .inProgress: return "orange"
        case .closed: return "green"
        }
    }
}

// MARK: - Create/Update Inspection
struct CreateInspectionRequest: Codable {
    let unitNumber: String
    let inspectorId: String
    let startDate: String
    let startTime: String?
}

struct UpdateInspectionRequest: Codable {
    let status: String?
    let startTime: String?
    let endTime: String?
    let smokeDetectorsCount: Int?
    let coDetectorsCount: Int?
}

struct SubmitInspectionRequest: Codable {
    let endTime: String
    let completionDate: String
}

struct InspectionCreateResponse: Codable {
    let message: String
    let soNumber: String
}
