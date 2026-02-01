//
//  SignupView.swift
//  PHAInspection
//
//  Inspector signup/registration screen
//

import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var inspectorId = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var vehicleTagId = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Side - Branding
                VStack {
                    Spacer()

                    VStack(spacing: 24) {
                        // Logo
                        Image("locomex-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            Text("Locomex")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)

                            Text("Assetim")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))

                            Rectangle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 60, height: 3)
                                .padding(.top, 8)

                            Text("Create your inspector account")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }

                    Spacer()

                    Text("Version 1.0.0 • Enterprise Edition")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 40)
                }
                .frame(width: geometry.size.width * 0.45)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "6BA876"),  // Locomex Logo Green (darker)
                            Color(hex: "7CB083"),  // Locomex Logo Green (exact match)
                            Color(hex: "8DBE95")   // Locomex Logo Green (lighter)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Right Side - Signup Form
                VStack {
                    Spacer()

                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "111827"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text("Register as a new inspector")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                        .padding(.top, 20)

                        // Form
                        ScrollView {
                            VStack(spacing: 20) {
                                // Name Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Full Name")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextField("Enter your full name", text: $name)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1.5)
                                        )
                                        .autocapitalization(.words)
                                        .autocorrectionDisabled()
                                }

                                // Inspector ID Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Inspector ID")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextField("Choose an inspector ID", text: $inspectorId)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1.5)
                                        )
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                }

                                // Vehicle Tag ID Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Vehicle Tag ID")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextField("Enter vehicle tag ID", text: $vehicleTagId)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1.5)
                                        )
                                        .autocapitalization(.allCharacters)
                                        .autocorrectionDisabled()
                                }

                                // Password Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Password")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    SecureField("Create a password", text: $password)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1.5)
                                        )
                                }

                                // Confirm Password Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Confirm Password")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    SecureField("Confirm your password", text: $confirmPassword)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: "D1D5DB"), lineWidth: 1.5)
                                        )
                                }

                                // Success Message
                                if let successMessage = successMessage {
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "7CB083"))

                                        Text(successMessage)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "5A9461"))

                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(Color(hex: "E8F5E9"))
                                    .cornerRadius(10)
                                }

                                // Error Message
                                if let errorMessage = errorMessage {
                                    HStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "DC2626"))

                                        Text(errorMessage)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "DC2626"))

                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(Color(hex: "FEE2E2"))
                                    .cornerRadius(10)
                                }

                                // Create Account Button
                                Button(action: signup) {
                                    HStack(spacing: 10) {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Create Account")
                                                .font(.system(size: 17, weight: .semibold))

                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "7CB083"),
                                                Color(hex: "5A9461")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(10)
                                    .shadow(color: Color(hex: "7CB083").opacity(0.25), radius: 10, x: 0, y: 3)
                                }
                                .disabled(isLoading || !isFormValid)
                                .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)

                                // Footer
                                HStack(spacing: 8) {
                                    Text("Already have an account?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "6B7280"))

                                    Button(action: { dismiss() }) {
                                        Text("Sign In")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "7CB083"))
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .frame(height: 540)
                    }
                    .padding(.horizontal, 50)
                    .frame(maxWidth: 500)

                    Spacer()
                }
                .frame(width: geometry.size.width * 0.55)
                .background(Color(hex: "FFFFFF"))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !name.isEmpty &&
        !inspectorId.isEmpty &&
        !vehicleTagId.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }

    // MARK: - Signup Function
    private func signup() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }

        // Validate password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }

        Task {
            do {
                // Call the backend API to create inspector
                let createRequest = CreateInspectorRequest(
                    inspectorId: inspectorId,
                    name: name,
                    vehicleTagId: vehicleTagId,
                    password: password
                )

                let _: CreateInspectorResponse = try await APIService.shared.request(
                    endpoint: APIConfig.Endpoints.createInspector,
                    method: .post,
                    body: createRequest,
                    requiresAuth: false
                )

                await MainActor.run {
                    successMessage = "Account created successfully! You can now sign in."
                    isLoading = false

                    // Dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Supporting Types
struct CreateInspectorRequest: Codable {
    let inspectorId: String
    let name: String
    let vehicleTagId: String
    let password: String
}

struct CreateInspectorResponse: Codable {
    let message: String
    let inspectorId: String
}


#Preview {
    SignupView()
}