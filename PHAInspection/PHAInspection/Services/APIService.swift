//
//  APIService.swift
//  PHA Inspection App
//
//  Core API Service using URLSession
//

import Foundation

class APIService {
    static let shared = APIService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(APIConfig.Headers.applicationJSON, forHTTPHeaderField: APIConfig.Headers.contentType)

        // Add authentication if required
        if requiresAuth {
            if let token = AuthManager.shared.getToken() {
                let bearerToken = APIConfig.Headers.bearerToken(token)
                request.setValue(bearerToken, forHTTPHeaderField: APIConfig.Headers.authorization)
                print("🔐 [APIService] Request to: \(url)")
                print("🔐 [APIService] Auth header: \(bearerToken.prefix(50))...")
            } else {
                print("❌ [APIService] No token found for authenticated request")
                throw NetworkError.unauthorized
            }
        }

        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        // Perform request
        print("📡 [APIService] \(method.rawValue) \(endpoint)")
        let (data, response) = try await session.data(for: request)

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        print("📥 [APIService] Response status: \(httpResponse.statusCode)")

        // Handle different status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            print("✅ [APIService] Success")
            do {
                let result = try decoder.decode(T.self, from: data)
                return result
            } catch {
                print("❌ [APIService] Decoding error: \(error)")
                throw NetworkError.decodingError(error)
            }

        case 401:
            print("❌ [APIService] Unauthorized (401)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [APIService] Response body: \(responseString)")
            }
            throw NetworkError.unauthorized

        case 400...599:
            // Try to decode error message
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw NetworkError.serverError(httpResponse.statusCode, errorResponse.error)
            } else {
                throw NetworkError.serverError(httpResponse.statusCode, nil)
            }

        default:
            throw NetworkError.unknown
        }
    }

    // MARK: - Request without response body (for DELETE)
    func requestNoResponse(
        endpoint: String,
        method: HTTPMethod = .delete,
        requiresAuth: Bool = true
    ) async throws {
        // Build URL
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add authentication if required
        if requiresAuth {
            if let token = AuthManager.shared.getToken() {
                request.setValue(
                    APIConfig.Headers.bearerToken(token),
                    forHTTPHeaderField: APIConfig.Headers.authorization
                )
            } else {
                throw NetworkError.unauthorized
            }
        }

        // Perform request
        let (_, response) = try await session.data(for: request)

        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        // Handle status codes
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            } else {
                throw NetworkError.serverError(httpResponse.statusCode, nil)
            }
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
