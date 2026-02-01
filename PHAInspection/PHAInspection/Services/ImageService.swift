//
//  ImageService.swift
//  PHA Inspection App
//
//  Image Upload and Management Service
//

import Foundation
import UIKit

class ImageService {
    static let shared = ImageService()

    private init() {}

    // MARK: - Upload Image
    func uploadImage(
        soNumber: String,
        itemId: String?,
        image: UIImage,
        caption: String? = nil
    ) async throws -> InspectionImageDTO {
        // Resize image if needed
        guard let resizedImage = image.resizeForUpload(maxDimension: 1920) else {
            throw NetworkError.unknown
        }

        // Compress image
        guard let imageData = resizedImage.compressForUpload(maxSizeKB: 500) else {
            throw NetworkError.unknown
        }

        // Convert to base64
        let base64String = imageData.base64EncodedString()

        // Create request
        let request = UploadImageRequest(
            soNumber: soNumber,
            itemId: itemId,
            caption: caption,
            imageData: base64String,
            mimeType: "image/jpeg",
            fileName: "inspection_\(UUID().uuidString).jpg"
        )

        let endpoint = APIConfig.Endpoints.uploadImage(soNumber)
        return try await APIService.shared.request(
            endpoint: endpoint,
            method: .post,
            body: request
        )
    }

    // MARK: - Get Images for Inspection
    func getImages(soNumber: String) async throws -> [InspectionImageDTO] {
        let endpoint = APIConfig.Endpoints.inspectionImages(soNumber)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Get Single Image
    func getImage(soNumber: String, imageId: String) async throws -> InspectionImageDTO {
        let endpoint = APIConfig.Endpoints.inspectionImage(soNumber, imageId)
        return try await APIService.shared.request(endpoint: endpoint)
    }

    // MARK: - Delete Image
    func deleteImage(soNumber: String, imageId: String) async throws {
        let endpoint = APIConfig.Endpoints.inspectionImage(soNumber, imageId)
        try await APIService.shared.requestNoResponse(
            endpoint: endpoint,
            method: .delete
        )
    }

    // MARK: - Download Image from URL
    func downloadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NetworkError.serverError(statusCode, "Failed to download image")
        }

        guard let image = UIImage(data: data) else {
            throw NetworkError.decodingError(NSError(
                domain: "ImageService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]
            ))
        }

        return image
    }
}
