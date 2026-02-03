//
//  APIConfig.swift
//  PHA Inspection App
//
//  API Configuration and Constants
//

import Foundation

struct APIConfig {
    // MARK: - Base URL
    // Railway deployment URL
    static let baseURL = "https://pha-inspection-system-production.up.railway.app/api"

    // MARK: - Endpoints
    struct Endpoints {
        // Authentication
        static let login = "/auth/login"
        static let createInspector = "/auth/create-inspector"

        // Dashboard
        static let dashboardSummary = "/dashboard/summary"

        // Inspections
        static let inspections = "/inspections"
        static func inspection(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)"
        }
        static func submitInspection(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/submit"
        }

        // Inspection Areas
        static let inspectionAreas = "/inspections/areas"
        static let inspectionAreaItems = "/inspections/areas/items"

        // Inspection Responses
        static func inspectionResponses(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/responses"
        }
        static func inspectionResponse(_ soNumber: String, _ itemId: String) -> String {
            return "/inspections/\(soNumber)/responses/\(itemId)"
        }

        // PMI
        static let pmiCategories = "/pmi/categories"
        static func pmiItems(_ categoryId: String) -> String {
            return "/pmi/categories/\(categoryId)/items"
        }
        static func pmiResponses(_ soNumber: String) -> String {
            return "/pmi/inspections/\(soNumber)/responses"
        }
        static func pmiResponse(_ soNumber: String, _ itemId: String) -> String {
            return "/pmi/inspections/\(soNumber)/responses/\(itemId)"
        }

        // Images
        static func inspectionImages(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/images"
        }
        static func inspectionImage(_ soNumber: String, _ imageId: String) -> String {
            return "/inspections/\(soNumber)/images/\(imageId)"
        }
        static func uploadImage(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/images/upload"
        }

        // Signatures
        static func inspectionSignatures(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/signatures"
        }
        static func inspectionSignature(_ soNumber: String, _ signatureId: String) -> String {
            return "/inspections/\(soNumber)/signatures/\(signatureId)"
        }
        static func uploadSignature(_ soNumber: String) -> String {
            return "/inspections/\(soNumber)/signatures/upload"
        }
    }

    // MARK: - Headers
    struct Headers {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let applicationJSON = "application/json"

        static func bearerToken(_ token: String) -> String {
            return "Bearer \(token)"
        }
    }
}
