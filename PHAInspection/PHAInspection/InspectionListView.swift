//
//  InspectionListView.swift
//  PHAInspection
//
//  Inspection list with filters and pagination
//

import SwiftUI

struct InspectionListView: View {
    @StateObject private var authManager = AuthManager.shared
    @AppStorage("hasSeenInspectionListTour") private var hasSeenTour = false

    @State private var inspections: [InspectionSummary] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @State private var selectedStatus: String = "All"
    @State private var selectedArea: String = "All"
    @State private var selectedSite: String = "All"
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 0
    @State private var totalElements: Int = 0
    @State private var showHelpSheet = false
    @State private var showOnboarding = false
    @State private var showCreateInspection = false

    let statuses = ["All", "New", "InProgress", "Closed"]
    let areas = ["All", "SS", "CS", "AMPB", "PAPMC"]
    let sites = ["All", "901", "902", "903", "904", "905"]
    let pageSize = 20

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView

                Divider()

                // Content
                if isLoading && inspections.isEmpty {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error: error)
                } else if inspections.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showHelpSheet) {
            HelpSheet(screenName: "Inspections") {
                // Restart tour callback
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showCreateInspection) {
            CreateInspectionView()
        }
        .overlay {
            if showOnboarding {
                OnboardingOverlay(isPresented: $showOnboarding, steps: HelpContent.inspectionListSteps)
            }
        }
        .onAppear {
            loadInspections()
            // Show onboarding on first launch
            if !hasSeenTour {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showOnboarding = true
                    hasSeenTour = true
                }
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            // Top Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inspections")
                        .font(.system(size: 32, weight: .bold))
                    Text("\(totalElements) total inspections")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Inspector Info & Logout
                if let inspector = authManager.currentInspector {
                    HStack(spacing: 20) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "7CB083"),
                                            Color(hex: "5A9461")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(inspector.name.prefix(1)))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(inspector.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "111827"))

                                Text("Inspector ID: \(inspector.id)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "6B7280"))
                            }
                        }

                        Button(action: { authManager.logout() }) {
                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "DC2626"))
                        }
                        .padding(8)
                        .background(Color(hex: "FEE2E2"))
                        .cornerRadius(8)
                    }
                }
            }

            // Filters
            HStack(spacing: 16) {
                Menu {
                    ForEach(statuses, id: \.self) { status in
                        Button(status) {
                            selectedStatus = status
                            currentPage = 0
                            loadInspections()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Status:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(selectedStatus)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }

                Menu {
                    ForEach(areas, id: \.self) { area in
                        Button(area) {
                            selectedArea = area
                            currentPage = 0
                            loadInspections()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Area:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(selectedArea)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }

                Menu {
                    ForEach(sites, id: \.self) { site in
                        Button(site) {
                            selectedSite = site
                            currentPage = 0
                            loadInspections()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Site:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(selectedSite)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(8)
                }

                Spacer()

                HStack(spacing: 12) {
                    // Create Inspection Button
                    Button(action: { showCreateInspection = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "7CB083"))
                            .padding(12)
                            .background(Color(hex: "7CB083").opacity(0.1))
                            .clipShape(Circle())
                    }

                    // Help Button
                    HelpButton(action: { showHelpSheet = true })

                    // Refresh Button
                    Button(action: {
                        currentPage = 0
                        loadInspections()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(inspections, id: \.soNumber) { inspection in
                        NavigationLink(destination: InspectionDetailView(soNumber: inspection.soNumber)) {
                            InspectionRow(inspection: inspection)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(24)
            }

            // Pagination
            if totalPages > 1 {
                paginationView
            }
        }
    }

    // MARK: - Pagination View
    private var paginationView: some View {
        HStack(spacing: 16) {
            Button(action: {
                if currentPage > 0 {
                    currentPage -= 1
                    loadInspections()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Previous")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(currentPage > 0 ? .blue : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(8)
            }
            .disabled(currentPage == 0)

            Text("Page \(currentPage + 1) of \(totalPages)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Button(action: {
                if currentPage < totalPages - 1 {
                    currentPage += 1
                    loadInspections()
                }
            }) {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(currentPage < totalPages - 1 ? .blue : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(8)
            }
            .disabled(currentPage >= totalPages - 1)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Loading/Error/Empty Views
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading inspections...")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding(.top, 16)
            Spacer()
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text(error)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                loadInspections()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(10)
            Spacer()
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No inspections found")
                .font(.system(size: 18, weight: .semibold))
            Text("Try adjusting your filters")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Load Inspections
    private func loadInspections() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Convert string status to enum
                let statusEnum: InspectionStatus?
                if selectedStatus == "All" {
                    statusEnum = nil
                } else if selectedStatus == "New" {
                    statusEnum = .new
                } else if selectedStatus == "InProgress" {
                    statusEnum = .inProgress
                } else if selectedStatus == "Closed" {
                    statusEnum = .closed
                } else {
                    statusEnum = nil
                }

                let area = selectedArea == "All" ? nil : selectedArea
                let siteCode = selectedSite == "All" ? nil : selectedSite

                let data = try await InspectionService.shared.getInspections(
                    status: statusEnum,
                    area: area,
                    siteCode: siteCode,
                    page: currentPage,
                    size: pageSize
                )

                await MainActor.run {
                    self.inspections = data.content
                    self.totalPages = data.totalPages
                    self.totalElements = data.totalElements
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Inspection Row
struct InspectionRow: View {
    let inspection: InspectionSummary

    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            statusBadge

            // Main Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SO# \(inspection.soNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(inspection.soDate)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(inspection.siteName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Unit \(inspection.unitNumber)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                if let tenantName = inspection.tenantName {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(tenantName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                }

                if let completionDate = inspection.completionDate {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Completed: \(completionDate)")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                    }
                }
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var statusBadge: some View {
        VStack {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            Spacer()
        }
    }

    private var statusColor: Color {
        switch inspection.status {
        case .new:
            return .blue
        case .inProgress:
            return .orange
        case .closed:
            return .green
        }
    }
}

#Preview {
    InspectionListView()
}