//
//  Inspector.swift
//  PHA Inspection App
//
//  Model for Inspector entity
//

import Foundation

struct Inspector: Codable, Identifiable {
    let id: String
    let name: String
    let vehicleTagId: String?
    let active: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "inspectorId"
        case name
        case vehicleTagId
        case active
        case createdAt
    }
}

// MARK: - Login Request/Response
struct LoginRequest: Codable {
    let inspectorId: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int
    let inspector: InspectorDTO
}

struct InspectorDTO: Codable {
    let id: String
    let name: String
    let vehicleTagId: String?

    enum CodingKeys: String, CodingKey {
        case id = "inspectorId"
        case name
        case vehicleTagId
    }
}
