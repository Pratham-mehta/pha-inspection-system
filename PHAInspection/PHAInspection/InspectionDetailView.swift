//
//  InspectionDetailView.swift
//  PHAInspection
//
//  Inspection detail form with full information and actions
//

import SwiftUI

struct InspectionDetailView: View {
    let soNumber: String

    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenInspectionDetailTour") private var hasSeenTour = false

    @State private var inspection: Inspection?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingSubmitAlert = false
    @State private var isSubmitting = false
    @State private var navigateToChecklist = false
    @State private var showHelpSheet = false
    @State private var showTenantAcknowledgement = false

    // Editable fields
    @State private var startDate = Date()
    @State private var startTime = Date()
    @State private var endDate = Date()
    @State private var endTime = Date()
    @State private var smokeDetectorsCount: Int = 0
    @State private var coDetectorsCount: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error: error)
                } else if let inspection = inspection {
                    contentView(inspection: inspection)
                }
            }
            .navigationTitle("Inspection Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Button("Close") {
                            dismiss()
                        }

                        // Help Button
                        HelpButton(action: { showHelpSheet = true })
                            .scaleEffect(0.9)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if let inspection = inspection, inspection.status != .closed {
                        Button("Save") {
                            updateInspection()
                        }
                        .disabled(isSubmitting)
                    }
                }
            }
            .sheet(isPresented: $showHelpSheet) {
                HelpSheet(screenName: "InspectionDetail")
            }
            .sheet(isPresented: $showTenantAcknowledgement) {
                if let inspection = inspection {
                    TenantAcknowledgementView(
                        inspection: inspection,
                        smokeDetectorsCount: $smokeDetectorsCount,
                        coDetectorsCount: $coDetectorsCount
                    )
                }
            }
            .onAppear {
                loadInspection()
            }
            .alert("Submit Inspection", isPresented: $showingSubmitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Submit", role: .destructive) {
                    submitInspection()
                }
            } message: {
                Text("Are you sure you want to submit this inspection? This action cannot be undone.")
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading inspection...")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Error Loading Inspection")
                .font(.system(size: 24, weight: .bold))

            Text(error)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: loadInspection) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "7CB083"))
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // MARK: - Content View
    private func contentView(inspection: Inspection) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Header
                statusHeader(inspection: inspection)

                // Unit Information
                unitInfoSection(inspection: inspection)

                // Tenant Information
                tenantInfoSection(inspection: inspection)

                // Inspection Details
                inspectionDetailsSection(inspection: inspection)

                // Date & Time Section
                dateTimeSection(inspection: inspection)

                // Detectors Section
                detectorsSection()

                // Action Buttons
                actionButtonsSection(inspection: inspection)
            }
            .padding()
        }
    }

    // MARK: - Status Header
    private func statusHeader(inspection: Inspection) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("SO #\(inspection.soNumber)")
                    .font(.system(size: 28, weight: .bold))

                Spacer()

                statusBadge(status: inspection.status.displayName)
            }

            if let completionDate = inspection.completionDate {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed on \(completionDate)")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func statusBadge(status: String) -> some View {
        Text(status)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(statusColor(status: status))
            .cornerRadius(8)
    }

    private func statusColor(status: String) -> Color {
        switch status {
        case "New": return Color.blue
        case "InProgress": return Color.orange
        case "Closed": return Color.green
        default: return Color.gray
        }
    }

    // MARK: - Unit Information Section
    private func unitInfoSection(inspection: Inspection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Unit Information")

            infoRow(icon: "building.2.fill", label: "Site", value: "\(inspection.siteCode) - \(inspection.siteName ?? "N/A")")
            infoRow(icon: "house.fill", label: "Unit", value: inspection.unitNumber)
            infoRow(icon: "location.fill", label: "Address", value: inspection.address)
            infoRow(icon: "bed.double.fill", label: "Bedrooms", value: "\(inspection.brSize ?? 0) BR")
            infoRow(icon: "bolt.fill", label: "Hardwired", value: (inspection.isHardwired ?? false) ? "Yes" : "No")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Tenant Information Section
    private func tenantInfoSection(inspection: Inspection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Tenant Information")

            infoRow(icon: "person.fill", label: "Name", value: inspection.tenantName ?? "N/A")

            if let phone = inspection.tenantPhone {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(Color(hex: "7CB083"))
                        .frame(width: 24)
                    Text("Phone")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 120, alignment: .leading)

                    Button(action: {
                        if let url = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(phone)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "7CB083"))
                    }

                    Spacer()
                }
            }

            infoRow(icon: "calendar.badge.clock", label: "Available", value: (inspection.tenantAvailability ?? false) ? "Yes" : "No")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Inspection Details Section
    private func inspectionDetailsSection(inspection: Inspection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Inspection Details")

            infoRow(icon: "doc.text.fill", label: "Division", value: inspection.divisionCode ?? "N/A")
            infoRow(icon: "person.badge.shield.checkmark.fill", label: "Inspector", value: inspection.inspectorName ?? "Unassigned")

            if let vehicleTag = inspection.vehicleTagId {
                infoRow(icon: "car.fill", label: "Vehicle Tag", value: vehicleTag)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Date & Time Section
    private func dateTimeSection(inspection: Inspection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Schedule")

            if inspection.status != .closed {
                // Editable date/time pickers
                VStack(alignment: .leading, spacing: 12) {
                    Text("Start Date & Time")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)

                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("End Date & Time")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)

                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // Read-only display
                infoRow(icon: "calendar", label: "Start", value: "\(inspection.startDate ?? "N/A") \(inspection.startTime ?? "")")
                infoRow(icon: "calendar", label: "End", value: "\(inspection.endDate ?? "N/A") \(inspection.endTime ?? "")")

                if let submitTime = inspection.submitTime {
                    infoRow(icon: "checkmark.circle", label: "Submitted", value: submitTime)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Detectors Section
    private func detectorsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Smoke & CO Detectors")

            VStack(spacing: 16) {
                // Smoke Detectors
                HStack {
                    Image(systemName: "smoke.fill")
                        .foregroundColor(Color(hex: "7CB083"))
                        .frame(width: 24)
                    Text("Smoke Detectors")
                        .font(.system(size: 15, weight: .medium))

                    Spacer()

                    Stepper(value: $smokeDetectorsCount, in: 0...20) {
                        Text("\(smokeDetectorsCount)")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 40)
                    }
                }

                // CO Detectors
                HStack {
                    Image(systemName: "aqi.medium")
                        .foregroundColor(Color(hex: "7CB083"))
                        .frame(width: 24)
                    Text("CO Detectors")
                        .font(.system(size: 15, weight: .medium))

                    Spacer()

                    Stepper(value: $coDetectorsCount, in: 0...20) {
                        Text("\(coDetectorsCount)")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Action Buttons Section
    private func actionButtonsSection(inspection: Inspection) -> some View {
        VStack(spacing: 16) {
            if inspection.status != .closed {
                // Start Inspection Button
                NavigationLink(destination: InspectionChecklistView(inspection: inspection)) {
                    HStack {
                        Image(systemName: "list.clipboard.fill")
                            .font(.system(size: 18))
                        Text("Start Inspection Checklist")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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

                // PMI Checklist Button
                NavigationLink(destination: PMIChecklistView(inspection: inspection)) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 18))
                        Text("Start PMI Checklist")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "8DBE95"),
                                Color(hex: "7CB083")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(hex: "8DBE95").opacity(0.3), radius: 8, x: 0, y: 4)
                }

                // Photos Button
                NavigationLink(destination: ImageGalleryView(inspection: inspection)) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.fill")
                            .font(.system(size: 18))
                        Text("View Photos")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "7CB083"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "7CB083"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                // Tenant Acknowledgement Button
                Button(action: { showTenantAcknowledgement = true }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 18))
                        Text("Tenant Acknowledgement")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "6366F1"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                // Submit Inspection Button
                Button(action: {
                    showingSubmitAlert = true
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Submit Inspection")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isSubmitting)
            } else {
                // Inspection Closed - View Only
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.green)
                    Text("Inspection Completed")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helper Views
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(hex: "111827"))
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "7CB083"))
                .frame(width: 24)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.system(size: 16))
            Spacer()
        }
    }

    // MARK: - API Functions
    private func loadInspection() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let loadedInspection = try await InspectionService.shared.getInspection(soNumber: soNumber)

                await MainActor.run {
                    self.inspection = loadedInspection

                    // Initialize editable fields
                    if let startDateStr = loadedInspection.startDate {
                        self.startDate = dateFromString(startDateStr) ?? Date()
                    }
                    if let startTimeStr = loadedInspection.startTime {
                        self.startTime = timeFromString(startTimeStr) ?? Date()
                    }
                    if let endDateStr = loadedInspection.endDate {
                        self.endDate = dateFromString(endDateStr) ?? Date()
                    }
                    if let endTimeStr = loadedInspection.endTime {
                        self.endTime = timeFromString(endTimeStr) ?? Date()
                    }

                    self.smokeDetectorsCount = loadedInspection.smokeDetectorsCount ?? 0
                    self.coDetectorsCount = loadedInspection.coDetectorsCount ?? 0

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

    private func updateInspection() {
        Task {
            do {
                let request = UpdateInspectionRequest(
                    status: nil,
                    startDate: dateToString(startDate),
                    startTime: timeToString(startTime),
                    endDate: dateToString(endDate),
                    endTime: timeToString(endTime),
                    smokeDetectorsCount: smokeDetectorsCount,
                    coDetectorsCount: coDetectorsCount
                )

                try await InspectionService.shared.updateInspection(soNumber: soNumber, request: request)

                await MainActor.run {
                    // Reload inspection to get updated data
                    loadInspection()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func submitInspection() {
        isSubmitting = true

        Task {
            do {
                let request = SubmitInspectionRequest(
                    endTime: timeToString(endTime),
                    completionDate: dateToString(Date())
                )

                try await InspectionService.shared.submitInspection(soNumber: soNumber, request: request)

                await MainActor.run {
                    self.isSubmitting = false
                    // Reload to show updated status
                    loadInspection()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSubmitting = false
                }
            }
        }
    }

    // MARK: - Date/Time Helpers
    private func dateFromString(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)
    }

    private func timeFromString(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.date(from: str)
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func timeToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

#Preview {
    InspectionDetailView(soNumber: "3184947")
}
