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

    // MARK: - Get Areas with Items (Combined)
    func getAreasWithItems() async throws -> [InspectionAreaModel] {
        // Get all areas
        let areas = try await getAllAreas()

        // Fetch items for each area concurrently
        return try await withThrowingTaskGroup(of: InspectionAreaModel.self) { group in
            for area in areas {
                group.addTask {
                    let itemDTOs = try await self.getItemsByArea(areaName: area.areaName)

                    // Convert DTOs to simple models
                    let items = itemDTOs.map { dto in
                        InspectionItem(
                            id: dto.id,
                            description: dto.description,
                            sortOrder: dto.sortOrder
                        )
                    }.sorted { $0.sortOrder < $1.sortOrder }

                    return InspectionAreaModel(
                        id: area.id,
                        areaName: area.areaName,
                        sortOrder: area.sortOrder,
                        items: items
                    )
                }
            }

            // Collect results and sort by sortOrder
            var results: [InspectionAreaModel] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.sortOrder < $1.sortOrder }
        }
    }
}
