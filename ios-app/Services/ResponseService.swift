//
//  ResponseService.swift
//  PHA Inspection App
//
//  Inspection Response API Service
//

import Foundation

class ResponseService {
    static let shared = ResponseService()

    private init() {}

    // MARK: - Get All Responses for Inspection
    func getResponses(soNumber: String) async throws -> [InspectionResponseDTO] {
        let endpoint = APIConfig.Endpoints.inspectionResponses(soNumber)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get Single Response
    func getResponse(soNumber: String, itemId: String) async throws -> InspectionResponseDTO {
        let endpoint = APIConfig.Endpoints.inspectionResponse(soNumber, itemId)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Create/Update Response
    func saveResponse(soNumber: String, request: CreateResponseRequest) async throws -> InspectionResponseDTO {
        let endpoint = APIConfig.Endpoints.inspectionResponses(soNumber)
        return try await APIService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
    }

    // MARK: - Delete Response
    func deleteResponse(soNumber: String, itemId: String) async throws {
        let endpoint = APIConfig.Endpoints.inspectionResponse(soNumber, itemId)
        try await APIService.shared.requestNoResponse(
            endpoint: endpoint,
            method: .delete
        )
    }
}
