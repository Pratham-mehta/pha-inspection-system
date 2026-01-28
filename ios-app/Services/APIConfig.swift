//
//  APIConfig.swift
//  PHA Inspection App
//
//  API Configuration and Constants
//

import Foundation

struct APIConfig {
    // MARK: - Base URL
    #if DEBUG
    static let baseURL = "http://localhost:8080/api"
    #else
    static let baseURL = "https://your-production-server.com/api"
    #endif

    // MARK: - Endpoints
    struct Endpoints {
        // Authentication
        static let login = "/auth/login"
        static let createInspector = "/auth/create"

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
