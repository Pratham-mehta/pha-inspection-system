//
//  InspectionResponse.swift
//  PHA Inspection App
//
//  Model for Inspection Responses
//

import Foundation

// MARK: - Inspection Response
struct InspectionResponseDTO: Codable, Identifiable {
    let id: String
    let response: ResponseType
    let scopeOfWork: String?
    let materialRequired: Bool
    let materialDescription: String?
    let serviceId: String?
    let activityCode: String?
    let tenantCharge: Bool
    let urgent: Bool
    let rrp: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case response
        case scopeOfWork
        case materialRequired
        case materialDescription
        case serviceId
        case activityCode
        case tenantCharge
        case urgent
        case rrp
        case createdAt
    }
}

// MARK: - Response Type Enum
enum ResponseType: String, Codable {
    case ok = "OK"
    case na = "NA"
    case def = "Def"

    var displayName: String {
        switch self {
        case .ok: return "OK"
        case .na: return "N/A"
        case .def: return "Deficiency"
        }
    }

    var color: String {
        switch self {
        case .ok: return "green"
        case .na: return "gray"
        case .def: return "red"
        }
    }
}

// MARK: - Create Response Request
struct CreateResponseRequest: Codable {
    let itemId: String
    let response: String
    let scopeOfWork: String?
    let materialRequired: Bool?
    let materialDescription: String?
    let serviceId: String?
    let activityCode: String?
    let tenantCharge: Bool?
    let urgent: Bool?
    let rrp: Bool?

    init(
        itemId: String,
        response: ResponseType,
        scopeOfWork: String? = nil,
        materialRequired: Bool? = nil,
        materialDescription: String? = nil,
        serviceId: String? = nil,
        activityCode: String? = nil,
        tenantCharge: Bool? = nil,
        urgent: Bool? = nil,
        rrp: Bool? = nil
    ) {
        self.itemId = itemId
        self.response = response.rawValue
        self.scopeOfWork = scopeOfWork
        self.materialRequired = materialRequired
        self.materialDescription = materialDescription
        self.serviceId = serviceId
        self.activityCode = activityCode
        self.tenantCharge = tenantCharge
        self.urgent = urgent
        self.rrp = rrp
    }
}
