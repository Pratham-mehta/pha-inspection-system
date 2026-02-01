//
//  CreateInspectionView.swift
//  PHAInspection
//
//  Created for PHA Inspection System
//  Allows inspectors to create new service orders with Area/Year/Month selection
//

import SwiftUI

struct CreateInspectionView: View {
    // MARK: - Properties
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State
    @State private var selectedArea: String = "SS"
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedSiteCode: String = ""
    @State private var siteName: String = ""
    @State private var unitNumber: String = ""
    @State private var address: String = ""
    @State private var divisionCode: String = ""
    @State private var tenantName: String = ""
    @State private var tenantPhone: String = ""
    @State private var brSize: Int = 2
    @State private var isHardwired: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()

    // MARK: - UI State
    @State private var isCreating: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert: Bool = false
    @State private var createdSONumber: String?

    // MARK: - Constants
    let areas = ["SS", "CS", "AMPB", "PAPMC"]
    let years = Array(2004...2025).reversed()
    let months = [
        (1, "January"), (2, "February"), (3, "March"), (4, "April"),
        (5, "May"), (6, "June"), (7, "July"), (8, "August"),
        (9, "September"), (10, "October"), (11, "November"), (12, "December")
    ]

    // Site mapping by area
    let sitesByArea: [String: [(code: String, name: String)]] = [
        "SS": [
            ("901", "Haddington"),
            ("902", "Mantua"),
            ("903", "Strawberry Mansion"),
            ("904", "Fairhill")
        ],
        "CS": [
            ("801", "Queen Lane"),
            ("802", "Spring Garden"),
            ("803", "Westpark")
        ],
        "AMPB": [
            ("701", "Martin Luther King"),
            ("702", "Richard Allen")
        ],
        "PAPMC": [
            ("601", "Wilson Park"),
            ("602", "Paschall")
        ]
    ]

    var availableSites: [(code: String, name: String)] {
        sitesByArea[selectedArea] ?? []
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Context Section
                    contextSection

                    // Site Selection
                    siteSection

                    // Unit Information
                    unitInfoSection

                    // Tenant Information (Optional)
                    tenantSection

                    // Schedule
                    scheduleSection

                    // Error Display
                    if let error = errorMessage {
                        errorView(error)
                    }

                    // Create Button
                    createButton
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("New Service Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Service Order Created", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("SO #\(createdSONumber ?? "") created successfully")
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "7CB083"))
            Text("Create New Service Order")
                .font(.system(size: 24, weight: .bold))
            Text("Fill in the details below")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
    }

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Inspection Context", icon: "calendar")

            // Area Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Area")
                    .font(.system(size: 14, weight: .semibold))
                Menu {
                    ForEach(areas, id: \.self) { area in
                        Button(area) {
                            selectedArea = area
                            // Reset site selection when area changes
                            selectedSiteCode = ""
                            siteName = ""
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedArea)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
            }

            // Year Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Year")
                    .font(.system(size: 14, weight: .semibold))
                Menu {
                    ForEach(years, id: \.self) { year in
                        Button("\(year)") {
                            selectedYear = year
                        }
                    }
                } label: {
                    HStack {
                        Text("\(selectedYear)")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
            }

            // Month Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Month")
                    .font(.system(size: 14, weight: .semibold))
                Menu {
                    ForEach(months, id: \.0) { month in
                        Button(month.1) {
                            selectedMonth = month.0
                        }
                    }
                } label: {
                    HStack {
                        Text(months.first(where: { $0.0 == selectedMonth })?.1 ?? "")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }

    private var siteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Site Selection", icon: "building.2")

            // Site Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Site")
                    .font(.system(size: 14, weight: .semibold))
                Menu {
                    ForEach(availableSites, id: \.code) { site in
                        Button("\(site.code) - \(site.name)") {
                            selectedSiteCode = site.code
                            siteName = site.name
                        }
                    }
                } label: {
                    HStack {
                        if selectedSiteCode.isEmpty {
                            Text("Select a site")
                                .foregroundColor(.gray)
                        } else {
                            Text("\(selectedSiteCode) - \(siteName)")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
            }

            // Division Code
            textField(label: "Division Code", text: $divisionCode, placeholder: "e.g., D1")
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }

    private var unitInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Unit Information", icon: "house")

            textField(label: "Unit Number", text: $unitNumber, placeholder: "e.g., 041529")
            textField(label: "Address", text: $address, placeholder: "Full unit address")

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bedroom Size")
                        .font(.system(size: 14, weight: .semibold))
                    Stepper(value: $brSize, in: 0...10) {
                        Text("\(brSize)")
                            .font(.system(size: 16))
                    }
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hardwired")
                        .font(.system(size: 14, weight: .semibold))
                    Toggle("", isOn: $isHardwired)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "7CB083")))
                        .padding(12)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }

    private var tenantSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Tenant Information (Optional)", icon: "person")

            textField(label: "Tenant Name", text: $tenantName, placeholder: "Full name")
            textField(label: "Tenant Phone", text: $tenantPhone, placeholder: "+1 (215) 555-1234")
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Schedule", icon: "clock")

            VStack(alignment: .leading, spacing: 8) {
                Text("Inspection Date")
                    .font(.system(size: 14, weight: .semibold))
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Start Time")
                    .font(.system(size: 14, weight: .semibold))
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }

    private var createButton: some View {
        Button(action: createInspection) {
            HStack(spacing: 12) {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Service Order")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "7CB083"), Color(hex: "5A9461")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(isCreating || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "7CB083"))
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
    }

    private func textField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
            TextField(placeholder, text: text)
                .padding(16)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
        }
    }

    private func errorView(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color(hex: "DC2626"))
            Text(message)
                .foregroundColor(Color(hex: "DC2626"))
                .font(.system(size: 14))
            Spacer()
        }
        .padding(16)
        .background(Color(hex: "FEE2E2"))
        .cornerRadius(12)
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !unitNumber.isEmpty &&
        !selectedSiteCode.isEmpty &&
        !address.isEmpty &&
        !divisionCode.isEmpty
    }

    // MARK: - Actions

    private func createInspection() {
        guard let inspector = authManager.currentInspector else {
            errorMessage = "No inspector logged in"
            return
        }

        isCreating = true
        errorMessage = nil

        Task {
            do {
                // Format date and time
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let startDateStr = dateFormatter.string(from: selectedDate)

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                let startTimeStr = timeFormatter.string(from: selectedTime)

                // Build request
                let request = CreateInspectionRequest(
                    unitNumber: unitNumber,
                    siteCode: selectedSiteCode,
                    siteName: siteName,
                    address: address,
                    divisionCode: divisionCode,
                    inspectorId: inspector.id,
                    inspectorName: inspector.name,
                    vehicleTagId: inspector.vehicleTagId ?? "",
                    startDate: startDateStr,
                    startTime: startTimeStr,
                    tenantName: tenantName.isEmpty ? nil : tenantName,
                    tenantPhone: tenantPhone.isEmpty ? nil : tenantPhone,
                    tenantAvailability: true,
                    brSize: brSize,
                    isHardwired: isHardwired
                )

                // Call API
                let response = try await InspectionService.shared.createInspection(request: request)

                await MainActor.run {
                    createdSONumber = response.soNumber
                    showSuccessAlert = true
                    isCreating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Preview

struct CreateInspectionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateInspectionView()
    }
}
