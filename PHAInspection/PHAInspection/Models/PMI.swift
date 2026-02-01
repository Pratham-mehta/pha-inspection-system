//
//  PMI.swift
//  PHA Inspection App
//
//  Model for PMI (Preventive Maintenance Inspection)
//

import Foundation

// MARK: - PMI Category DTO
struct PMICategoryDTO: Codable, Identifiable {
    let id: String
    let name: String
    let sortOrder: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name
        case sortOrder
        case isActive
    }
}

// MARK: - PMI Item
struct PMIItemDTO: Codable, Identifiable {
    let id: String
    let categoryId: String
    let description: String
    let sortOrder: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case categoryId
        case description
        case sortOrder
        case isActive
    }
}

// MARK: - PMI Response
struct PMIResponseDTO: Codable, Identifiable {
    let id: String
    let categoryId: String
    let completed: Bool
    let notes: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case categoryId
        case completed
        case notes
        case createdAt
    }
}

// MARK: - Create PMI Response Request
struct CreatePMIResponseRequest: Codable {
    let itemId: String
    let categoryId: String
    let completed: Bool
    let notes: String?
}

// MARK: - Type Alias for Convenience
typealias PMIResponse = PMIResponseDTO

// MARK: - Combined Models for Checklist
struct PMICategoryModel: Identifiable, Hashable {
    let id: String
    let name: String
    let sortOrder: Int
    let items: [PMIItemModel]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PMICategoryModel, rhs: PMICategoryModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct PMIItemModel: Identifiable, Hashable {
    let id: String
    let categoryId: String
    let description: String
    let sortOrder: Int
}
