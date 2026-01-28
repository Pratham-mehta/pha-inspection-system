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
}
