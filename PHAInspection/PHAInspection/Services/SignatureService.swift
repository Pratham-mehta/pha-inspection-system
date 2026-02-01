//
//  SignatureService.swift
//  PHA Inspection App
//
//  Signature Upload and Management Service
//

import Foundation
import UIKit

class SignatureService {
    static let shared = SignatureService()

    private init() {}

    // MARK: - Upload Signature
    func uploadSignature(
        soNumber: String,
        signatureType: String,
        signedBy: String,
        signature: UIImage
    ) async throws -> InspectionSignatureDTO {
        // Convert signature to PNG data
        guard let imageData = signature.pngData() else {
            throw NetworkError.unknown
        }

        // Convert to base64
        let base64String = imageData.base64EncodedString()

        // Create request
        let request = UploadSignatureRequest(
            soNumber: soNumber,
            signatureType: signatureType,
            signedBy: signedBy,
            signatureData: base64String,
            fileName: "signature_\(signatureType)_\(UUID().uuidString).png"
        )

        let endpoint = APIConfig.Endpoints.uploadSignature(soNumber)
        return try await APIService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
    }

    // MARK: - Get Signatures for Inspection
    func getSignatures(soNumber: String) async throws -> [InspectionSignatureDTO] {
        let endpoint = APIConfig.Endpoints.inspectionSignatures(soNumber)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get Single Signature
    func getSignature(soNumber: String, signatureId: String) async throws -> InspectionSignatureDTO {
        let endpoint = APIConfig.Endpoints.inspectionSignature(soNumber, signatureId)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Delete Signature
    func deleteSignature(soNumber: String, signatureId: String) async throws {
        let endpoint = APIConfig.Endpoints.inspectionSignature(soNumber, signatureId)
        try await APIService.shared.requestNoResponse(
            endpoint: endpoint,
            method: .delete
        )
    }

    // MARK: - Download Signature from URL
    func downloadSignature(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NetworkError.serverError(statusCode, "Failed to download signature")
        }

        guard let image = UIImage(data: data) else {
            throw NetworkError.decodingError(NSError(
                domain: "SignatureService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid signature data"]
            ))
        }

        return image
    }
}
