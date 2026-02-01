//
//  LocomexColors.swift
//  PHAInspection
//
//  Locomex brand colors extracted from logo
//

import SwiftUI

extension Color {
    // MARK: - Locomex Brand Colors
    // Extracted from the Locomex logo (sage/mint green)

    /// Primary brand color from logo - Sage Green
    static let locomexPrimary = Color(hex: "7CB083")

    /// Dark variant for gradients and accents
    static let locomexDark = Color(hex: "5A9461")

    /// Light variant for gradients
    static let locomexLight = Color(hex: "9BC5A0")

    /// Very light variant for backgrounds
    static let locomexBackground = Color(hex: "E8F5E9")

    /// Subtle tint for hover states
    static let locomexTint = Color(hex: "A8D5AE")
}

// MARK: - Usage Guide
/*
 Replace these colors throughout the app:

 OLD                      → NEW
 Color(hex: "10B981")     → Color.locomexPrimary
 Color(hex: "059669")     → Color.locomexDark
 Color(hex: "34D399")     → Color.locomexLight
 Color(hex: "D1FAE5")     → Color.locomexBackground
 */