//
//  DashboardService.swift
//  PHA Inspection App
//
//  Dashboard API Service
//

import Foundation

class DashboardService {
    static let shared = DashboardService()

    private init() {}

    // MARK: - Get Dashboard Summary
    func getDashboardSummary(
        area: String? = nil,
        year: Int? = nil,
        month: Int? = nil,
        siteCode: String? = nil
    ) async throws -> DashboardSummary {
        var endpoint = APIConfig.Endpoints.dashboardSummary + "?"

        var params: [String] = []

        if let area = area {
            params.append("area=\(area)")
        }
        if let year = year {
            params.append("year=\(year)")
        }
        if let month = month {
            params.append("month=\(month)")
        }
        if let siteCode = siteCode {
            params.append("siteCode=\(siteCode)")
        }

        endpoint += params.joined(separator: "&")

        return try await APIService.shared.request(endpoint: endpoint)
    }
}
