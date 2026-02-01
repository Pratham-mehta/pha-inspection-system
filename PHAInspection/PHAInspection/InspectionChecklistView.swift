//
//  InspectionChecklistView.swift
//  PHAInspection
//
//  Room-by-room inspection checklist with OK/NA/Def responses
//

import SwiftUI

struct InspectionChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection

    @State private var areas: [InspectionAreaModel] = []
    @State private var selectedArea: InspectionAreaModel?
    @State private var responses: [String: InspectionResponse] = [:]
    @State private var isLoadingAreas = false
    @State private var isLoadingResponses = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let responseService = ResponseService.shared
    private let areaService = InspectionAreaService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection

                if isLoadingAreas {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    // Area List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(areas) { area in
                                areaCard(area)
                            }
                        }
                        .padding(24)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedArea) { area in
                InspectionAreaItemsView(
                    inspection: inspection,
                    area: area,
                    responses: $responses
                )
            }
        }
        .onAppear {
            loadAreasAndResponses()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "7CB083"))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("SO #\(inspection.soNumber)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "111827"))
                    Text("\(inspection.siteName ?? "Unknown Site")")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.white)

            Divider()

            // Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inspection Checklist")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("Tap an area to start inspection")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)

            Divider()
        }
    }

    // MARK: - Area Card
    private func areaCard(_ area: InspectionAreaModel) -> some View {
        let areaResponses = responses.values.filter { response in
            area.items.contains { $0.id == response.id }
        }
        let completedCount = areaResponses.count
        let totalCount = area.items.count
        let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0

        return Button(action: {
            selectedArea = area
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(area.areaName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))

                        Text("\(totalCount) items to inspect")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "7CB083"))
                }

                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(completedCount) of \(totalCount) completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "7CB083"))
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "E5E7EB"))
                                .frame(height: 8)

                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "7CB083"),
                                            Color(hex: "5A9461")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Loading/Error Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading inspection areas...")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "DC2626"))

            Text("Error Loading Checklist")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: loadAreasAndResponses) {
                Text("Retry")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "7CB083"))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - Data Loading
    private func loadAreasAndResponses() {
        isLoadingAreas = true
        errorMessage = nil

        Task {
            do {
                // Load areas with items
                let loadedAreas = try await areaService.getAreasWithItems()

                // Load existing responses
                let loadedResponses = try await responseService.getResponses(soNumber: inspection.soNumber)
                var responsesDict: [String: InspectionResponse] = [:]
                for response in loadedResponses {
                    responsesDict[response.id] = response
                }

                await MainActor.run {
                    self.areas = loadedAreas
                    self.responses = responsesDict
                    self.isLoadingAreas = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingAreas = false
                }
            }
        }
    }
}

// MARK: - Inspection Area Items View
struct InspectionAreaItemsView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    let area: InspectionAreaModel
    @Binding var responses: [String: InspectionResponse]

    @State private var selectedItem: InspectionItem?
    @State private var showDeficiencyForm = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false

    private let responseService = ResponseService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            areaHeaderSection

            // Items List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(area.items) { item in
                        itemCard(item)
                    }
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "7CB083"))
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            DeficiencyFormView(
                inspection: inspection,
                item: item,
                existingResponse: responses[item.id],
                onSave: { response in
                    responses[item.id] = response
                    selectedItem = nil
                    showSuccess(message: "Deficiency saved successfully")
                }
            )
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage ?? "")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Area Header
    private var areaHeaderSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(area.areaName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("\(area.items.count) items • SO #\(inspection.soNumber)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)

            Divider()
        }
    }

    // MARK: - Item Card
    private func itemCard(_ item: InspectionItem) -> some View {
        let response = responses[item.id]

        return VStack(alignment: .leading, spacing: 16) {
            // Item Description
            Text(item.description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "111827"))
                .fixedSize(horizontal: false, vertical: true)

            // Response Buttons
            HStack(spacing: 12) {
                responseButton(
                    title: "OK",
                    type: .ok,
                    item: item,
                    isSelected: response?.response == .ok
                )

                responseButton(
                    title: "NA",
                    type: .na,
                    item: item,
                    isSelected: response?.response == .na
                )

                responseButton(
                    title: "Def",
                    type: .def,
                    item: item,
                    isSelected: response?.response == .def
                )
            }

            // Show deficiency details if exists
            if let response = response, response.response == .def {
                deficiencySummary(response, item: item)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Response Button
    private func responseButton(title: String, type: ResponseType, item: InspectionItem, isSelected: Bool) -> some View {
        Button(action: {
            handleResponse(type: type, item: item)
        }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : buttonTextColor(type))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Group {
                        if isSelected {
                            buttonSelectedBackground(type)
                        } else {
                            buttonBackground(type)
                        }
                    }
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func buttonTextColor(_ type: ResponseType) -> Color {
        switch type {
        case .ok: return Color(hex: "059669")
        case .na: return Color(hex: "6B7280")
        case .def: return Color(hex: "DC2626")
        }
    }

    private func buttonBackground(_ type: ResponseType) -> Color {
        switch type {
        case .ok: return Color(hex: "D1FAE5")
        case .na: return Color(hex: "F3F4F6")
        case .def: return Color(hex: "FEE2E2")
        }
    }

    private func buttonSelectedBackground(_ type: ResponseType) -> some View {
        Group {
            switch type {
            case .ok:
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "059669"), Color(hex: "047857")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .na:
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "6B7280"), Color(hex: "4B5563")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            case .def:
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "DC2626"), Color(hex: "B91C1C")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }

    // MARK: - Deficiency Summary
    private func deficiencySummary(_ response: InspectionResponse, item: InspectionItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let scope = response.scopeOfWork {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "wrench.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "DC2626"))
                            Text("Scope: \(scope)")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "374151"))
                        }
                    }

                    if let serviceId = response.serviceId {
                        HStack(spacing: 8) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "DC2626"))
                            Text("Service: \(serviceId)")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "374151"))
                        }
                    }
                }

                Spacer()

                Button(action: {
                    selectedItem = item
                }) {
                    Text("Edit")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "7CB083"))
                }
            }
        }
        .padding(12)
        .background(Color(hex: "FEE2E2").opacity(0.5))
        .cornerRadius(8)
    }

    // MARK: - Handle Response
    private func handleResponse(type: ResponseType, item: InspectionItem) {
        if type == .def {
            // Show deficiency form
            selectedItem = item
        } else {
            // Save OK or NA response directly
            saveResponse(type: type, item: item)
        }
    }

    private func saveResponse(type: ResponseType, item: InspectionItem) {
        isSaving = true

        Task {
            do {
                let request = CreateResponseRequest(
                    itemId: item.id,
                    response: type,
                    scopeOfWork: nil,
                    materialRequired: nil,
                    materialDescription: nil,
                    serviceId: nil,
                    activityCode: nil,
                    tenantCharge: nil,
                    urgent: nil,
                    rrp: nil
                )

                let response = try await responseService.createResponse(
                    soNumber: inspection.soNumber,
                    request: request
                )

                await MainActor.run {
                    self.responses[item.id] = response
                    self.isSaving = false
                    self.showSuccess(message: "Response saved successfully")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isSaving = false
                }
            }
        }
    }

    private func showSuccess(message: String) {
        successMessage = message
        showSuccess = true
    }
}

// MARK: - Deficiency Form View
struct DeficiencyFormView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    let item: InspectionItem
    let existingResponse: InspectionResponse?
    let onSave: (InspectionResponse) -> Void

    @State private var scopeOfWork: String
    @State private var materialRequired: Bool
    @State private var materialDescription: String
    @State private var serviceId: String
    @State private var activityCode: String
    @State private var tenantCharge: Bool
    @State private var urgent: Bool
    @State private var rrp: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let responseService = ResponseService.shared

    init(inspection: Inspection, item: InspectionItem, existingResponse: InspectionResponse?, onSave: @escaping (InspectionResponse) -> Void) {
        self.inspection = inspection
        self.item = item
        self.existingResponse = existingResponse
        self.onSave = onSave

        // Initialize with existing values or defaults
        _scopeOfWork = State(initialValue: existingResponse?.scopeOfWork ?? "")
        _materialRequired = State(initialValue: existingResponse?.materialRequired ?? false)
        _materialDescription = State(initialValue: existingResponse?.materialDescription ?? "")
        _serviceId = State(initialValue: existingResponse?.serviceId ?? "")
        _activityCode = State(initialValue: existingResponse?.activityCode ?? "")
        _tenantCharge = State(initialValue: existingResponse?.tenantCharge ?? false)
        _urgent = State(initialValue: existingResponse?.urgent ?? false)
        _rrp = State(initialValue: existingResponse?.rrp ?? false)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Item Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deficiency Details")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))

                        Text(item.description)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Scope of Work
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scope of Work")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "374151"))

                        TextField("Describe the repair needed...", text: $scopeOfWork, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .lineLimit(3...6)
                    }

                    // Service ID and Activity Code
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Service ID")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))

                            TextField("e.g., 100-PLUMBING", text: $serviceId)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity Code")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))

                            TextField("e.g., 703", text: $activityCode)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    // Material Required
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $materialRequired) {
                            Text("Material Required")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))
                        }
                        .tint(Color(hex: "7CB083"))

                        if materialRequired {
                            TextField("Describe materials needed...", text: $materialDescription, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .lineLimit(2...4)
                        }
                    }

                    // Flags
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $tenantCharge) {
                            Text("Tenant Charge")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))
                        }
                        .tint(Color(hex: "7CB083"))

                        Toggle(isOn: $urgent) {
                            Text("Urgent")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))
                        }
                        .tint(Color(hex: "7CB083"))

                        Toggle(isOn: $rrp) {
                            Text("RRP (Lead-Safe Work)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "374151"))
                        }
                        .tint(Color(hex: "7CB083"))
                    }

                    // Save Button
                    Button(action: saveDeficiency) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }

                            Text(isSaving ? "Saving..." : "Save Deficiency")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "DC2626"),
                                    Color(hex: "B91C1C")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "DC2626").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "6B7280"))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var isFormValid: Bool {
        !scopeOfWork.trimmingCharacters(in: .whitespaces).isEmpty &&
        !serviceId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !activityCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveDeficiency() {
        isSaving = true

        Task {
            do {
                let request = CreateResponseRequest(
                    itemId: item.id,
                    response: .def,
                    scopeOfWork: scopeOfWork,
                    materialRequired: materialRequired,
                    materialDescription: materialRequired ? materialDescription : nil,
                    serviceId: serviceId,
                    activityCode: activityCode,
                    tenantCharge: tenantCharge,
                    urgent: urgent,
                    rrp: rrp
                )

                let response = try await responseService.createResponse(
                    soNumber: inspection.soNumber,
                    request: request
                )

                await MainActor.run {
                    self.isSaving = false
                    self.onSave(response)
                    self.dismiss()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isSaving = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    InspectionChecklistView(
        inspection: Inspection(
            id: "3184947",
            unitNumber: "041529",
            siteCode: "901",
            siteName: "Haddington",
            divisionCode: "D1",
            address: "123 Main St, Philadelphia, PA 19139",
            tenantName: "John Doe",
            tenantPhone: "+12155551234",
            tenantAvailability: true,
            brSize: 2,
            isHardwired: false,
            status: .inProgress,
            inspectorName: "IOSTEST",
            vehicleTagId: "Q",
            startDate: "2025-05-02",
            startTime: "08:30:00",
            endDate: nil,
            endTime: nil,
            submitTime: nil,
            smokeDetectorsCount: 5,
            coDetectorsCount: 3,
            completionDate: nil,
            createdAt: "2025-01-15T10:00:00Z",
            updatedAt: "2025-05-02T08:30:00Z"
        )
    )
}
