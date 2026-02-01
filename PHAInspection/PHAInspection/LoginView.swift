//
//  LoginView.swift
//  PHAInspection
//
//  Login screen for inspectors
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var inspectorId = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignup = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Side - Branding
                VStack {
                    Spacer()

                    VStack(spacing: 24) {
                        // Logo - Replace with your actual logo
                        // Option 1: If you add "locomex-logo" to Assets.xcassets
                        Image("locomex-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)

                        // Option 2: Fallback to SF Symbol if logo not found
                        // Image(systemName: "building.2.fill")
                        //     .font(.system(size: 80, weight: .light))
                        //     .foregroundColor(.white.opacity(0.95))

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

                            Text("Asset Inspection Management System")
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

                // Right Side - Login Form
                VStack {
                    Spacer()

                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Sign In")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(hex: "111827"))

                            Text("Access your inspection dashboard")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "6B7280"))
                        }

                        // Form
                        VStack(spacing: 24) {
                            // Inspector ID Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Inspector ID")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "374151"))

                                TextField("Enter your inspector ID", text: $inspectorId)
                                    .font(.system(size: 17))
                                    .padding(16)
                                    .background(Color(hex: "F9FAFB"))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                                    )
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "374151"))

                                SecureField("Enter your password", text: $password)
                                    .font(.system(size: 17))
                                    .padding(16)
                                    .background(Color(hex: "F9FAFB"))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
                                    )
                            }

                            // Error Message
                            if let errorMessage = errorMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "DC2626"))

                                    Text(errorMessage)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "DC2626"))

                                    Spacer()
                                }
                                .padding(16)
                                .background(Color(hex: "FEE2E2"))
                                .cornerRadius(12)
                            }

                            // Login Button
                            Button(action: login) {
                                HStack(spacing: 12) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Sign In")
                                            .font(.system(size: 18, weight: .semibold))

                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "7CB083"),  // Locomex Primary
                                            Color(hex: "5A9461")   // Locomex Dark
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "7CB083").opacity(0.3), radius: 12, x: 0, y: 4)
                            }
                            .disabled(isLoading || inspectorId.isEmpty || password.isEmpty)
                            .opacity((isLoading || inspectorId.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                        }

                        // Footer
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color(hex: "E5E7EB"))
                                .frame(height: 1)

                            Text("Need Help?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "6B7280"))

                            Rectangle()
                                .fill(Color(hex: "E5E7EB"))
                                .frame(height: 1)
                        }
                        .padding(.top, 16)

                        Button(action: {
                            showSignup = true
                        }) {
                            Text("Create New Account")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "7CB083"))  // Locomex Primary
                        }
                    }
                    .padding(.horizontal, 60)
                    .frame(maxWidth: 520)

                    Spacer()
                }
                .frame(width: geometry.size.width * 0.55)
                .background(Color(hex: "FFFFFF"))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSignup) {
            SignupView()
        }
    }

    // MARK: - Login Function
    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await authManager.login(
                    inspectorId: inspectorId,
                    password: password
                )
                // Navigation handled by @Published isAuthenticated in AuthManager
                await MainActor.run {
                    isLoading = false
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

#Preview {
    LoginView()
}