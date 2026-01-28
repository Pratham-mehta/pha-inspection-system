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
