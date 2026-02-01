//
//  HelpButton.swift
//  PHAInspection
//
//  Reusable help button component
//

import SwiftUI

struct HelpButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "7CB083").opacity(0.15),
                                Color(hex: "5A9461").opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "7CB083"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoBadge: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                Text(text)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(Color(hex: "7CB083"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "7CB083").opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HelpButton(action: {})
        InfoBadge(text: "What's this?", action: {})
    }
    .padding()
}
