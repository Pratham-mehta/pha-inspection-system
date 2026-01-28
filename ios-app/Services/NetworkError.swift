//
//  NetworkError.swift
//  PHA Inspection App
//
//  Network Error Handling
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized
    case networkFailure(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Error Response from API
struct APIErrorResponse: Codable {
    let error: String
    let message: String?
}
