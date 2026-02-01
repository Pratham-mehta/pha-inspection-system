//
//  InspectionArea.swift
//  PHA Inspection App
//
//  Model for Inspection Areas and Items
//

import Foundation

// MARK: - Inspection Area
struct InspectionAreaDTO: Codable, Identifiable {
    let id: String
    let sortOrder: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id = "areaName"
        case sortOrder
        case isActive
    }

    // Computed property for display
    var areaName: String {
        return id
    }
}

// MARK: - Inspection Item
struct InspectionItemDTO: Codable, Identifiable {
    let id: String
    let description: String
    let sortOrder: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case description
        case sortOrder
        case isActive
    }
}

// MARK: - Combined Model for Checklist
struct InspectionAreaModel: Identifiable, Hashable {
    let id: String
    let areaName: String
    let sortOrder: Int
    let items: [InspectionItem]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: InspectionAreaModel, rhs: InspectionAreaModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct InspectionItem: Identifiable, Hashable {
    let id: String
    let description: String
    let sortOrder: Int
}
