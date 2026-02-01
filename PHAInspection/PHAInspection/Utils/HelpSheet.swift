//
//  HelpSheet.swift
//  PHAInspection
//
//  Help modal sheet with glossary and guides
//

import SwiftUI

struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    let screenName: String
    let onRestartTour: (() -> Void)?

    @State private var selectedTab = 0

    init(screenName: String, onRestartTour: (() -> Void)? = nil) {
        self.screenName = screenName
        self.onRestartTour = onRestartTour
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Help & Guide")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))

                        Text("Learn how to use \(screenName)")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(24)
                .background(Color.white)

                // Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "Guide", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Glossary", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal, 24)
                .background(Color(UIColor.systemGroupedBackground))

                // Content
                if selectedTab == 0 {
                    guideTab
                } else {
                    glossaryTab
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // MARK: - Guide Tab
    private var guideTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(HelpContent.helpSheetContent(for: screenName))
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "374151"))
                    .fixedSize(horizontal: false, vertical: true)

                // Show Tour Again Button
                if onRestartTour != nil && hasTourForScreen() {
                    Divider()
                        .padding(.vertical, 8)

                    Button(action: {
                        dismiss()
                        // Small delay to let sheet dismiss before showing tour
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onRestartTour?()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 20))

                            Text("Show Interactive Tour Again")
                                .font(.system(size: 16, weight: .semibold))

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
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
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "7CB083").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(24)
        }
    }

    // Check if screen has a tour
    private func hasTourForScreen() -> Bool {
        switch screenName {
        case "Dashboard", "Inspections":
            return true
        default:
            return false
        }
    }

    // MARK: - Glossary Tab
    private var glossaryTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(HelpContent.glossary.keys.sorted()), id: \.self) { term in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(term)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))

                        Text(HelpContent.glossary[term] ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "6B7280"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .padding(24)
        }
    }

    // MARK: - Tab Button
    struct TabButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? Color(hex: "7CB083") : .secondary)

                    Rectangle()
                        .fill(isSelected ? Color(hex: "7CB083") : Color.clear)
                        .frame(height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Preview
#Preview {
    HelpSheet(screenName: "Dashboard")
}
