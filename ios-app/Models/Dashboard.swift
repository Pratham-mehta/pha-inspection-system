//
//  Dashboard.swift
//  PHA Inspection App
//
//  Model for Dashboard entity
//

import Foundation

// MARK: - Dashboard Summary
struct DashboardSummary: Codable {
    let filters: DashboardFilters
    let sites: [SiteSummary]
    let totals: StatusTotals
}

// MARK: - Dashboard Filters
struct DashboardFilters: Codable {
    let area: String?
    let year: Int?
    let month: Int?
    let siteCode: String?
}

// MARK: - Site Summary
struct SiteSummary: Codable, Identifiable {
    let id: String
    let siteName: String
    let newCount: Int
    let inProgressCount: Int
    let closedCount: Int
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case id = "siteCode"
        case siteName
        case newCount
        case inProgressCount
        case closedCount
        case totalCount
    }
}

// MARK: - Status Totals
struct StatusTotals: Codable {
    let new: Int
    let inProgress: Int
    let closed: Int
    let total: Int
}

// MARK: - Area Enum
enum Area: String, Codable, CaseIterable {
    case ss = "SS"
    case cs = "CS"
    case ampb = "AMPB"
    case papmc = "PAPMC"

    var displayName: String {
        switch self {
        case .ss: return "Scattered Sites"
        case .cs: return "Conventional Sites"
        case .ampb: return "AMPB"
        case .papmc: return "PAPMC"
        }
    }
}
