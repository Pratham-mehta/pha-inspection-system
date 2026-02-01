//
//  PMIService.swift
//  PHA Inspection App
//
//  PMI API Service
//

import Foundation

class PMIService {
    static let shared = PMIService()

    private init() {}

    // MARK: - Get All PMI Categories
    func getCategories() async throws -> [PMICategoryDTO] {
        return try await APIService.shared.request(endpoint: APIConfig.Endpoints.pmiCategories)
    }

    // MARK: - Get PMI Items by Category
    func getItems(categoryId: String) async throws -> [PMIItemDTO] {
        let endpoint = APIConfig.Endpoints.pmiItems(categoryId)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get PMI Responses
    func getResponses(soNumber: String) async throws -> [PMIResponseDTO] {
        let endpoint = APIConfig.Endpoints.pmiResponses(soNumber)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get Single PMI Response
    func getResponse(soNumber: String, itemId: String) async throws -> PMIResponseDTO {
        let endpoint = APIConfig.Endpoints.pmiResponse(soNumber, itemId)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Create/Update PMI Response
    func saveResponse(soNumber: String, request: CreatePMIResponseRequest) async throws -> PMIResponseDTO {
        let endpoint = APIConfig.Endpoints.pmiResponses(soNumber)
        return try await APIService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
    }

    // MARK: - Delete PMI Response
    func deleteResponse(soNumber: String, itemId: String) async throws {
        let endpoint = APIConfig.Endpoints.pmiResponse(soNumber, itemId)
        try await APIService.shared.requestNoResponse(
            endpoint: endpoint,
            method: .delete
        )
    }

    // MARK: - Get Categories with Items (Combined)
    func getCategoriesWithItems() async throws -> [PMICategoryModel] {
        // Get all categories
        let categories = try await getCategories()

        // Fetch items for each category concurrently
        return try await withThrowingTaskGroup(of: PMICategoryModel.self) { group in
            for category in categories {
                group.addTask {
                    let itemDTOs = try await self.getItems(categoryId: category.id)

                    // Convert DTOs to simple models
                    let items = itemDTOs.map { dto in
                        PMIItemModel(
                            id: dto.id,
                            categoryId: dto.categoryId,
                            description: dto.description,
                            sortOrder: dto.sortOrder
                        )
                    }.sorted { $0.sortOrder < $1.sortOrder }

                    return PMICategoryModel(
                        id: category.id,
                        name: category.name,
                        sortOrder: category.sortOrder,
                        items: items
                    )
                }
            }

            // Collect results and sort by sortOrder
            var results: [PMICategoryModel] = []
            for try await result in group {
                results.append(result)
            }
            return results.sorted { $0.sortOrder < $1.sortOrder }
        }
    }
}
