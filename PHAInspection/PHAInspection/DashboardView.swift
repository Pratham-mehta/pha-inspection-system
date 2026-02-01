//
//  DashboardView.swift
//  PHAInspection
//
//  Dashboard with filters and site summaries
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @AppStorage("hasSeenDashboardTour") private var hasSeenTour = false

    @State private var selectedArea: String = "All"
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var dashboardData: DashboardSummary?
    @State private var showHelpSheet = false
    @State private var showOnboarding = false

    let areas = ["All", "SS", "CS", "AMPB", "PAPMC"]
    let years = Array(2004...2025).reversed()
    let months = [
        (1, "January"), (2, "February"), (3, "March"), (4, "April"),
        (5, "May"), (6, "June"), (7, "July"), (8, "August"),
        (9, "September"), (10, "October"), (11, "November"), (12, "December")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Content
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error: error)
            } else if let data = dashboardData {
                contentView(data: data)
            } else {
                emptyView
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $showHelpSheet) {
            HelpSheet(screenName: "Dashboard") {
                // Restart tour callback
                showOnboarding = true
            }
        }
        .overlay {
            if showOnboarding {
                OnboardingOverlay(isPresented: $showOnboarding, steps: HelpContent.dashboardSteps)
            }
        }
        .onAppear {
            loadDashboard()
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
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                HStack(spacing: 16) {
                    // Logo in navigation
                    Image("locomex-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color(hex: "7CB083"))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Locomex")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))

                        Text("Asset Inspection Management")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
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
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

            // Page Header with Filters
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Dashboard Overview")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))

                        Text("Monitor and track inspection activities")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "6B7280"))
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        // Help Button
                        HelpButton(action: { showHelpSheet = true })

                        // Refresh Button
                        Button(action: loadDashboard) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .medium))

                                Text("Refresh")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "7CB083"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "E8F5E9"))
                            .cornerRadius(8)
                        }
                    }
                }

                // Filters Row
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "6B7280"))

                        Text("Filters:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "374151"))
                    }

                    Menu {
                        ForEach(areas, id: \.self) { area in
                            Button(area) {
                                selectedArea = area
                                loadDashboard()
                            }
                        }
                    } label: {
                        EnterpriseFilterButton(label: "Area", value: selectedArea)
                    }

                    Menu {
                        ForEach(years, id: \.self) { year in
                            Button(String(year)) {
                                selectedYear = year
                                loadDashboard()
                            }
                        }
                    } label: {
                        EnterpriseFilterButton(label: "", value: String(selectedYear))
                    }

                    Menu {
                        ForEach(months, id: \.0) { month in
                            Button(month.1) {
                                selectedMonth = month.0
                                loadDashboard()
                            }
                        }
                    } label: {
                        EnterpriseFilterButton(label: "", value: months.first(where: { $0.0 == selectedMonth })?.1 ?? "")
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(Color(hex: "F9FAFB"))
        }
    }

    // MARK: - Content View
    private func contentView(data: DashboardSummary) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Cards - Enterprise style
                HStack(spacing: 16) {
                    EnterpriseMetricCard(
                        title: "New",
                        value: "\(data.totals.new)",
                        icon: "doc.text",
                        accentColor: Color(hex: "3B82F6")
                    )
                    EnterpriseMetricCard(
                        title: "In Progress",
                        value: "\(data.totals.inProgress)",
                        icon: "clock",
                        accentColor: Color(hex: "F59E0B")
                    )
                    EnterpriseMetricCard(
                        title: "Closed",
                        value: "\(data.totals.closed)",
                        icon: "checkmark.circle",
                        accentColor: Color(hex: "7CB083")
                    )
                    EnterpriseMetricCard(
                        title: "Total Inspections",
                        value: "\(data.totals.total)",
                        icon: "list.bullet.clipboard",
                        accentColor: Color(hex: "6B7280")
                    )
                }
                .padding(.horizontal, 24)

                // Sites List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sites Overview")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "1F2937"))
                        .padding(.horizontal, 24)

                    LazyVStack(spacing: 12) {
                        ForEach(data.sites, id: \.siteCode) { site in
                            EnterpriseSiteCard(site: site)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 24)
        }
    }

    // MARK: - Loading/Error/Empty Views
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading dashboard...")
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
                loadDashboard()
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
        VStack {
            Spacer()
            Text("No data available")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Load Dashboard
    private func loadDashboard() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let area = selectedArea == "All" ? nil : selectedArea
                let data = try await DashboardService.shared.getDashboardSummary(
                    area: area,
                    year: selectedYear,
                    month: selectedMonth,
                    siteCode: nil
                )

                await MainActor.run {
                    self.dashboardData = data
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

// MARK: - Enterprise Filter Button
struct EnterpriseFilterButton: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            if !label.isEmpty {
                Text(label + ":")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
    }
}

// MARK: - Filter Button (Legacy - for InspectionListView)
struct FilterButton<Content: View>: View {
    let title: String
    let value: String
    let content: Content

    init(title: String, value: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }

    var body: some View {
        content
    }
}

struct FilterButtonLabel: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            if !title.isEmpty {
                Text(title + ":")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Text(value)
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
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Site Card
struct SiteCard: View {
    let site: SiteSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(site.siteName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Site Code: \(site.siteCode)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Total Badge
                Text("\(site.totalCount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(12)
            }

            // Status Badges
            HStack(spacing: 16) {
                StatusPill(label: "New", count: site.newCount, color: .blue)
                StatusPill(label: "In Progress", count: site.inProgressCount, color: .orange)
                StatusPill(label: "Closed", count: site.closedCount, color: .green)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Status Pill
struct StatusPill: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            Text("\(count)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .cornerRadius(20)
    }
}

// MARK: - Enterprise Metric Card
struct EnterpriseMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 40, height: 40)
                    .background(accentColor.opacity(0.1))
                    .cornerRadius(8)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Enterprise Site Card
struct EnterpriseSiteCard: View {
    let site: SiteSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(site.siteName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("Site Code: \(site.siteCode)")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                // Total Badge - Enterprise style
                Text("\(site.totalCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "374151"))
                    .frame(minWidth: 44)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(8)
            }

            // Divider
            Rectangle()
                .fill(Color(hex: "E5E7EB"))
                .frame(height: 1)

            // Status Stats - Table style
            HStack(spacing: 0) {
                EnterpriseStatusCell(
                    label: "New",
                    count: site.newCount,
                    color: Color(hex: "3B82F6")
                )

                Rectangle()
                    .fill(Color(hex: "E5E7EB"))
                    .frame(width: 1)

                EnterpriseStatusCell(
                    label: "In Progress",
                    count: site.inProgressCount,
                    color: Color(hex: "F59E0B")
                )

                Rectangle()
                    .fill(Color(hex: "E5E7EB"))
                    .frame(width: 1)

                EnterpriseStatusCell(
                    label: "Closed",
                    count: site.closedCount,
                    color: Color(hex: "7CB083")
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Enterprise Status Cell
struct EnterpriseStatusCell: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Text("\(count)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}


#Preview {
    DashboardView()
}