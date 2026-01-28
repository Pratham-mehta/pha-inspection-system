//
//  InspectionAreaService.swift
//  PHA Inspection App
//
//  Inspection Area API Service
//

import Foundation

class InspectionAreaService {
    static let shared = InspectionAreaService()

    private init() {}

    // MARK: - Get All Areas
    func getAllAreas() async throws -> [InspectionAreaDTO] {
        return try await APIService.shared.request(endpoint: APIConfig.Endpoints.inspectionAreas)
    }

    // MARK: - Get Items by Area
    func getItemsByArea(areaName: String) async throws -> [InspectionItemDTO] {
        // Encode area name for URL
        let encodedAreaName = areaName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? areaName
        let endpoint = APIConfig.Endpoints.inspectionAreaItems + "?areaName=\(encodedAreaName)"

        return try await APIService.shared.request(endpoint: endpoint)
    }
}
