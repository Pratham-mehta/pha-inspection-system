//
//  AuthManager.swift
//  PHA Inspection App
//
//  JWT Authentication Manager
//

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated: Bool = false
    @Published var currentInspector: InspectorDTO?

    private let tokenKey = "jwt_token"
    private let inspectorKey = "current_inspector"

    private init() {
        // Check if token exists on init
        loadAuthState()
    }

    // MARK: - Login
    func login(inspectorId: String, password: String) async throws -> LoginResponse {
        print("🔑 [AuthManager] Logging in with ID: \(inspectorId)")
        let request = LoginRequest(inspectorId: inspectorId, password: password)

        let response: LoginResponse = try await APIService.shared.request(
            endpoint: APIConfig.Endpoints.login,
            method: .post,
            body: request,
            requiresAuth: false
        )

        print("✅ [AuthManager] Login successful, token received")
        print("🔑 [AuthManager] Token: \(response.token.prefix(50))...")

        // Save token and inspector
        saveToken(response.token)
        saveInspector(response.inspector)

        // Update state on main thread
        await MainActor.run {
            self.isAuthenticated = true
            self.currentInspector = response.inspector
        }

        print("✅ [AuthManager] Auth state updated, isAuthenticated = true")
        return response
    }

    // MARK: - Logout
    func logout() {
        // Remove token and inspector
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: inspectorKey)

        // Update state
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentInspector = nil
        }
    }

    // MARK: - Token Management
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    // MARK: - Inspector Management
    private func saveInspector(_ inspector: InspectorDTO) {
        if let encoded = try? JSONEncoder().encode(inspector) {
            UserDefaults.standard.set(encoded, forKey: inspectorKey)
        }
    }

    private func loadInspector() -> InspectorDTO? {
        guard let data = UserDefaults.standard.data(forKey: inspectorKey),
              let inspector = try? JSONDecoder().decode(InspectorDTO.self, from: data) else {
            return nil
        }
        return inspector
    }

    // MARK: - Load Auth State
    private func loadAuthState() {
        if let token = getToken(), !token.isEmpty {
            self.isAuthenticated = true
            self.currentInspector = loadInspector()
        } else {
            self.isAuthenticated = false
            self.currentInspector = nil
        }
    }

    // MARK: - Check if Token is Expired (optional)
    func isTokenValid() -> Bool {
        guard let token = getToken() else { return false }

        // Decode JWT to check expiration
        // JWT format: header.payload.signature
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else { return false }

        // Decode payload (base64)
        let payloadSegment = segments[1]
        guard let payloadData = base64UrlDecode(payloadSegment) else { return false }

        // Parse JSON
        guard let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return false
        }

        // Check if expired
        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate > Date()
    }

    // MARK: - Base64 URL Decode
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length

        if paddingLength > 0 {
            let padding = String(repeating: "=", count: Int(paddingLength))
            base64 += padding
        }

        return Data(base64Encoded: base64)
    }
}
