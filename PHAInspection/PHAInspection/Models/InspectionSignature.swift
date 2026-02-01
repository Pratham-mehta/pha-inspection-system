//
//  InspectionSignature.swift
//  PHA Inspection App
//
//  Model for Inspection Signatures
//

import Foundation
import UIKit

// MARK: - Signature DTO (from/to backend)
struct InspectionSignatureDTO: Codable, Identifiable {
    let signatureId: String
    let soNumber: String
    let signatureUrl: String
    let signatureType: String // "inspector", "tenant"
    let signedBy: String
    let signedAt: String
    let fileSize: Int?

    var id: String { signatureId }
}

// MARK: - Upload Signature Request
struct UploadSignatureRequest: Codable {
    let soNumber: String
    let signatureType: String
    let signedBy: String
    let signatureData: String // Base64 encoded PNG
    let fileName: String
}

// MARK: - Local Signature Model (for UI)
struct InspectionSignatureModel: Identifiable {
    let id: String
    let soNumber: String
    let signatureType: String
    let signedBy: String
    let signature: UIImage
    let signedAt: Date?
    var isUploading: Bool = false
    var uploadError: String?

    init(dto: InspectionSignatureDTO, signature: UIImage) {
        self.id = dto.signatureId
        self.soNumber = dto.soNumber
        self.signatureType = dto.signatureType
        self.signedBy = dto.signedBy
        self.signature = signature
        self.signedAt = ISO8601DateFormatter().date(from: dto.signedAt)
        self.isUploading = false
        self.uploadError = nil
    }

    init(soNumber: String, signatureType: String, signedBy: String, signature: UIImage) {
        self.id = UUID().uuidString
        self.soNumber = soNumber
        self.signatureType = signatureType
        self.signedBy = signedBy
        self.signature = signature
        self.signedAt = Date()
        self.isUploading = true
        self.uploadError = nil
    }
}
