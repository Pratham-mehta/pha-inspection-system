//
//  PMIChecklistView.swift
//  PHAInspection
//
//  PMI (Preventive Maintenance Inspection) checklist with categories and items
//

import SwiftUI

struct PMIChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection

    @State private var categories: [PMICategoryModel] = []
    @State private var selectedCategory: PMICategoryModel?
    @State private var responses: [String: PMIResponse] = [:]
    @State private var isLoadingCategories = false
    @State private var errorMessage: String?

    private let pmiService = PMIService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection

                if isLoadingCategories {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    // Category List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(categories) { category in
                                categoryCard(category)
                            }
                        }
                        .padding(24)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedCategory) { category in
                PMICategoryItemsView(
                    inspection: inspection,
                    category: category,
                    responses: $responses
                )
            }
        }
        .onAppear {
            loadCategoriesAndResponses()
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
                    Text("PMI Checklist")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("Preventive Maintenance Inspection")
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

    // MARK: - Category Card
    private func categoryCard(_ category: PMICategoryModel) -> some View {
        let categoryResponses = responses.values.filter { response in
            category.items.contains { $0.id == response.id }
        }
        let completedCount = categoryResponses.filter { $0.completed }.count
        let totalCount = category.items.count
        let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0

        return Button(action: {
            selectedCategory = category
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(category.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))

                        Text("\(totalCount) maintenance items")
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
            Text("Loading PMI categories...")
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

            Text("Error Loading PMI Checklist")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: loadCategoriesAndResponses) {
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
    private func loadCategoriesAndResponses() {
        isLoadingCategories = true
        errorMessage = nil

        Task {
            do {
                // Load categories with items
                let loadedCategories = try await pmiService.getCategoriesWithItems()

                // Load existing responses
                let loadedResponses = try await pmiService.getResponses(soNumber: inspection.soNumber)
                var responsesDict: [String: PMIResponse] = [:]
                for response in loadedResponses {
                    responsesDict[response.id] = response
                }

                await MainActor.run {
                    self.categories = loadedCategories
                    self.responses = responsesDict
                    self.isLoadingCategories = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingCategories = false
                }
            }
        }
    }
}

// MARK: - PMI Category Items View
struct PMICategoryItemsView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    let category: PMICategoryModel
    @Binding var responses: [String: PMIResponse]

    @State private var selectedItem: PMIItemModel?
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false

    private let pmiService = PMIService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            categoryHeaderSection

            // Items List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(category.items) { item in
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
            PMINotesFormView(
                inspection: inspection,
                item: item,
                existingResponse: responses[item.id],
                onSave: { response in
                    responses[item.id] = response
                    selectedItem = nil
                    showSuccess(message: "PMI item saved successfully")
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

    // MARK: - Category Header
    private var categoryHeaderSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("\(category.items.count) items • SO #\(inspection.soNumber)")
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
    private func itemCard(_ item: PMIItemModel) -> some View {
        let response = responses[item.id]
        let isCompleted = response?.completed ?? false

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                // Checkbox
                Button(action: {
                    toggleCompletion(item: item)
                }) {
                    ZStack {
                        Circle()
                            .stroke(isCompleted ? Color(hex: "7CB083") : Color(hex: "D1D5DB"), lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isCompleted {
                            Circle()
                                .fill(Color(hex: "7CB083"))
                                .frame(width: 24, height: 24)

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Item Description
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "111827"))
                        .fixedSize(horizontal: false, vertical: true)

                    // Show notes if exists
                    if let notes = response?.notes, !notes.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "6B7280"))
                            Text(notes)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "6B7280"))
                                .lineLimit(2)
                        }
                        .padding(8)
                        .background(Color(hex: "F9FAFB"))
                        .cornerRadius(6)
                    }

                    // Add/Edit Notes Button
                    Button(action: {
                        selectedItem = item
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: response?.notes != nil ? "pencil" : "plus.circle")
                                .font(.system(size: 12))
                            Text(response?.notes != nil ? "Edit Notes" : "Add Notes")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "7CB083"))
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Toggle Completion
    private func toggleCompletion(item: PMIItemModel) {
        let currentResponse = responses[item.id]
        let newCompleted = !(currentResponse?.completed ?? false)
        let existingNotes = currentResponse?.notes

        isSaving = true

        Task {
            do {
                let request = CreatePMIResponseRequest(
                    itemId: item.id,
                    categoryId: item.categoryId,
                    completed: newCompleted,
                    notes: existingNotes
                )

                let response = try await pmiService.saveResponse(
                    soNumber: inspection.soNumber,
                    request: request
                )

                await MainActor.run {
                    self.responses[item.id] = response
                    self.isSaving = false
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

// MARK: - PMI Notes Form View
struct PMINotesFormView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    let item: PMIItemModel
    let existingResponse: PMIResponse?
    let onSave: (PMIResponse) -> Void

    @State private var notes: String
    @State private var completed: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false

    private let pmiService = PMIService.shared

    init(inspection: Inspection, item: PMIItemModel, existingResponse: PMIResponse?, onSave: @escaping (PMIResponse) -> Void) {
        self.inspection = inspection
        self.item = item
        self.existingResponse = existingResponse
        self.onSave = onSave

        // Initialize with existing values or defaults
        _notes = State(initialValue: existingResponse?.notes ?? "")
        _completed = State(initialValue: existingResponse?.completed ?? false)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Item Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PMI Notes")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "111827"))

                        Text(item.description)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Completed Toggle
                    Toggle(isOn: $completed) {
                        Text("Mark as Completed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "374151"))
                    }
                    .tint(Color(hex: "7CB083"))

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "374151"))

                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }

                    // Save Button
                    Button(action: saveNotes) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }

                            Text(isSaving ? "Saving..." : "Save")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
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
                    .disabled(isSaving)
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

    private func saveNotes() {
        isSaving = true

        Task {
            do {
                let request = CreatePMIResponseRequest(
                    itemId: item.id,
                    categoryId: item.categoryId,
                    completed: completed,
                    notes: notes.isEmpty ? nil : notes
                )

                let response = try await pmiService.saveResponse(
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
    PMIChecklistView(
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
