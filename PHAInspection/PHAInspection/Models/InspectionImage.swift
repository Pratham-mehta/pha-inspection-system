//
//  InspectionImage.swift
//  PHA Inspection App
//
//  Model for Inspection Images
//

import Foundation
import UIKit

// MARK: - Inspection Image DTO
struct InspectionImageDTO: Codable, Identifiable {
    let id: String
    let soNumber: String
    let itemId: String?
    let imageUrl: String
    let thumbnailUrl: String?
    let caption: String?
    let uploadedAt: String
    let fileSize: Int?
    let mimeType: String?

    enum CodingKeys: String, CodingKey {
        case id = "imageId"
        case soNumber
        case itemId
        case imageUrl
        case thumbnailUrl
        case caption
        case uploadedAt
        case fileSize
        case mimeType
    }
}

// MARK: - Upload Image Request
struct UploadImageRequest: Codable {
    let soNumber: String
    let itemId: String?
    let caption: String?
    let imageData: String // Base64 encoded
    let mimeType: String
    let fileName: String
}

// MARK: - Local Image Model (for UI)
struct InspectionImageModel: Identifiable {
    let id: String
    let soNumber: String
    let itemId: String?
    let image: UIImage
    let caption: String?
    let uploadedAt: Date?
    var isUploading: Bool = false
    var uploadError: String?

    // Create from captured image
    init(soNumber: String, itemId: String?, image: UIImage, caption: String? = nil) {
        self.id = UUID().uuidString
        self.soNumber = soNumber
        self.itemId = itemId
        self.image = image
        self.caption = caption
        self.uploadedAt = nil
        self.isUploading = false
        self.uploadError = nil
    }

    // Create from DTO (downloaded image)
    init(dto: InspectionImageDTO, image: UIImage) {
        self.id = dto.id
        self.soNumber = dto.soNumber
        self.itemId = dto.itemId
        self.image = image
        self.caption = dto.caption

        // Parse ISO 8601 date
        let formatter = ISO8601DateFormatter()
        self.uploadedAt = formatter.date(from: dto.uploadedAt)

        self.isUploading = false
        self.uploadError = nil
    }
}

// MARK: - Image Compression Utility
extension UIImage {
    func compressForUpload(maxSizeKB: Int = 500) -> Data? {
        // Start with high quality
        var compression: CGFloat = 0.9
        var imageData = self.jpegData(compressionQuality: compression)

        // Reduce quality until size is acceptable
        while let data = imageData, data.count > maxSizeKB * 1024 && compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    func resizeForUpload(maxDimension: CGFloat = 1920) -> UIImage? {
        let size = self.size

        // Check if resize needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }

        // Calculate new size maintaining aspect ratio
        let ratio = size.width / size.height
        let newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
        } else {
            newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
        }

        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
