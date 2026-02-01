//
//  PHAInspectionApp.swift
//  PHAInspection
//
//  Created by Pratham Mehta on 12/9/25.
//

import SwiftUI

@main
struct PHAInspectionApp: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
