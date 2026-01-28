//
//  InspectionService.swift
//  PHA Inspection App
//
//  Inspection API Service
//

import Foundation

class InspectionService {
    static let shared = InspectionService()

    private init() {}

    // MARK: - Get Inspections List
    func getInspections(
        status: InspectionStatus? = nil,
        area: String? = nil,
        siteCode: String? = nil,
        page: Int = 0,
        size: Int = 20
    ) async throws -> InspectionListResponse {
        var endpoint = APIConfig.Endpoints.inspections + "?page=\(page)&size=\(size)"

        if let status = status {
            endpoint += "&status=\(status.rawValue)"
        }
        if let area = area {
            endpoint += "&area=\(area)"
        }
        if let siteCode = siteCode {
            endpoint += "&siteCode=\(siteCode)"
        }

        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get Single Inspection
    func getInspection(soNumber: String) async throws -> Inspection {
        let endpoint = APIConfig.Endpoints.inspection(soNumber)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Create Inspection
    func createInspection(request: CreateInspectionRequest) async throws -> InspectionCreateResponse {
        return try await APIService.shared.request(
            endpoint: APIConfig.Endpoints.inspections,
            method: .post,
            body: request
        )
    }

    // MARK: - Update Inspection
    func updateInspection(soNumber: String, request: UpdateInspectionRequest) async throws {
        let endpoint = APIConfig.Endpoints.inspection(soNumber)
        let _: EmptyResponse = try await APIService.shared.request(
            endpoint: endpoint,
            method: .put,
            body: request
        )
    }

    // MARK: - Submit Inspection
    func submitInspection(soNumber: String, request: SubmitInspectionRequest) async throws {
        let endpoint = APIConfig.Endpoints.submitInspection(soNumber)
        let _: EmptyResponse = try await APIService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
    }
}

// MARK: - Empty Response Helper
private struct EmptyResponse: Codable {}
