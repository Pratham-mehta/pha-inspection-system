//
//  TenantAcknowledgementView.swift
//  PHAInspection
//
//  Tenant Acknowledgement of Receipt with Legal Disclaimer and Signature
//

import SwiftUI
import PencilKit

struct TenantAcknowledgementView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    @Binding var smokeDetectorsCount: Int
    @Binding var coDetectorsCount: Int

    @State private var showSignatureSection = false
    @State private var canvasDrawing = PKDrawing()
    @State private var isDrawing = false
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false

    // Signature persistence state
    @State private var isLoadingSignature = true
    @State private var existingSignature: InspectionSignatureDTO?
    @State private var signatureImage: UIImage?
    @State private var alreadySigned = false

    private let signatureService = SignatureService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Legal Acknowledgement Text
                    acknowledgementTextSection

                    // Detector Counts
                    detectorCountsSection

                    // Signature Section - Different UI based on whether already signed
                    if isLoadingSignature {
                        ProgressView("Loading signature...")
                            .padding(.top, 24)
                    } else if alreadySigned {
                        // Show existing signature (read-only)
                        existingSignatureView
                    } else {
                        // Allow new signature
                        if !showSignatureSection {
                            Button(action: { showSignatureSection = true }) {
                                Text("Show signature section")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "6366F1"))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "EEF2FF"))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 24)
                        }

                        // Signature Canvas Section
                        if showSignatureSection {
                            signatureSectionView
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color(hex: "F9FAFB"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Return")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "6366F1"))
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Tenant acknowledgement has been saved successfully. Signature uploaded to backend.")
            }
            .onAppear {
                checkForExistingSignature()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image("PHA-Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding(.top, 20)

            Text("Tenant Acknowledgement")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Divider()

            // Inspection Details
            VStack(spacing: 12) {
                HStack {
                    detailRow(label: "S/O #", value: inspection.soNumber)
                    Spacer()
                    detailRow(label: "Site", value: "\(inspection.siteCode) - \(inspection.siteName ?? "")")
                }

                HStack {
                    detailRow(label: "Unit", value: inspection.unitNumber)
                    Spacer()
                    detailRow(label: "Address", value: inspection.address)
                }

                HStack {
                    detailRow(label: "Tenant Name", value: inspection.tenantName ?? "")
                    Spacer()
                    detailRow(label: "Tenant Phone", value: inspection.tenantPhone ?? "")
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .background(Color.white)
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "111827"))
        }
    }

    // MARK: - Acknowledgement Text Section
    private var acknowledgementTextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TENANT ACKNOWLEDGEMENT OF RECEIPT OF LEAD VISUAL ASSESSMENT, INSTALLATION, AND RESPONSIBILITY FOR SMOKE DETECTOR(S), CARBON MONOXIDE DETECTOR(S) AND BATTERY(IES)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
                .multilineTextAlignment(.leading)

            Text("I, \(inspection.tenantName ?? "TENANT"), a Tenant of the Philadelphia Housing Authority (PHA) / Philadelphia Asset & Property Management Corporation (PAPMC), (whose signature appears on this document and PHA/PAPMC lease) acknowledge the receipt and installation of smoke detector(s) with batteries in the proper working order, as well as carbon monoxide detector(s).")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)

            Text("I understand that if I, or any household members or guests, damage the smoke/carbon monoxide detectors, that I will be responsible for the repair or replacement costs for the smoke/carbon monoxide detectors. The cost for replacement or repair shall be listed in the schedule of Maintenance Charges that is available, upon request, in the management office. I understand that I may request a grievance hearing if I disagree with the charge.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)

            Text("I further understand and acknowledge that all smoke detectors and carbon monoxide detectors are PHA property, and as such, shall be subject to inspection by PHA on a periodic basis.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)

            Text("I agree to report any non-functioning smoke detectors or carbon monoxide detectors to PHA by calling the work control center at 215-684-8920. PHA's replacement of smoke detectors, carbon monoxide detectors, and batteries will be determined through periodic inspections of all detectors. PHA does not assume liability for unreported malfunctioning smoke detectors or carbon monoxide detectors.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)

            Text("I, \(inspection.tenantName ?? "TENANT"), certify that I am a tenant at the above-referenced address and that a Visual Assessment for Deteriorated Paint was conducted in my unit on \(getCurrentDate()).")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)

            Text("I further certify that the results of the Visual Assessment were shared with me and that have I informed the Visual Assessor of any deteriorated paint that I have noticed in my unit. I understand that by signing this certification that I am agreeing that the results of the Visual Assessment are accurate and reflect the current condition of my unit.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .background(Color.white)
    }

    // MARK: - Detector Counts Section
    private var detectorCountsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("# of Smoke Detector(s) in the Unit:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Spacer()
                Text("\(smokeDetectorsCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
            }

            Divider()

            HStack {
                Text("# of Carbon Monoxide Detector(s) in the Unit:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Spacer()
                Text("\(coDetectorsCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
            }
        }
        .padding(24)
        .background(Color.white)
    }

    // MARK: - Signature Section
    private var signatureSectionView: some View {
        VStack(spacing: 16) {
            Text("Tenant Signature")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Canvas
            CanvasView(drawing: $canvasDrawing, isDrawing: $isDrawing)
                .frame(height: 300)
                .background(Color.white)
                .border(Color(hex: "D1D5DB"), width: 1)
                .cornerRadius(8)

            // Action Buttons
            HStack(spacing: 16) {
                // Clear Button
                Button(action: clearCanvas) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        Text("Clear")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "D1D5DB"), lineWidth: 2)
                    )
                }
                .disabled(!isDrawing)

                // Save Button
                Button(action: saveSignature) {
                    HStack(spacing: 8) {
                        if isUploading {
                            ProgressView()
                                .scaleEffect(0.9)
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                        }
                        Text(isUploading ? "Saving..." : "Save Acknowledgement")
                            .font(.system(size: 17, weight: .semibold))
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
                .disabled(!isDrawing || isUploading)
            }
        }
        .padding(24)
        .background(Color.white)
    }

    // MARK: - Existing Signature View (Read-Only)
    private var existingSignatureView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("✓ Already Signed")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "10B981"))

                    if let signature = existingSignature {
                        Text("Signed by: \(signature.signedBy)")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B7280"))

                        Text("Signed at: \(formatDate(signature.signedAt))")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Display saved signature image
            if let image = signatureImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .background(Color.white)
                    .border(Color(hex: "10B981"), width: 2)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
            }

            Text("This acknowledgement has already been signed and cannot be modified.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(hex: "F0FDF4"))
    }

    // MARK: - Helper Functions
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }

    private func clearCanvas() {
        canvasDrawing = PKDrawing()
        isDrawing = false
    }

    private func saveSignature() {
        isUploading = true

        // Convert PKDrawing to UIImage
        let image = canvasDrawing.image(from: canvasDrawing.bounds, scale: 2.0)

        let signedBy = inspection.tenantName ?? "Tenant"

        Task {
            do {
                let _ = try await signatureService.uploadSignature(
                    soNumber: inspection.soNumber,
                    signatureType: "tenant",
                    signedBy: signedBy,
                    signature: image
                )

                await MainActor.run {
                    self.isUploading = false
                    self.showSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isUploading = false
                }
            }
        }
    }

    private func checkForExistingSignature() {
        isLoadingSignature = true

        Task {
            do {
                // Fetch all signatures for this inspection
                let signatures = try await signatureService.getSignatures(soNumber: inspection.soNumber)

                // Look for tenant signature
                if let tenantSignature = signatures.first(where: { $0.signatureType == "tenant" }) {
                    // Signature exists - fetch the image
                    if let url = URL(string: tenantSignature.signatureUrl) {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                self.existingSignature = tenantSignature
                                self.signatureImage = image
                                self.alreadySigned = true
                                self.isLoadingSignature = false
                            }
                            return
                        }
                    }
                }

                // No signature found
                await MainActor.run {
                    self.alreadySigned = false
                    self.isLoadingSignature = false
                }
            } catch {
                // Error or no signatures found - allow signing
                await MainActor.run {
                    self.alreadySigned = false
                    self.isLoadingSignature = false
                }
            }
        }
    }
}

// MARK: - Canvas View (UIKit Bridge)
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isDrawing: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput  // Allow finger or Apple Pencil
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .white
        canvasView.drawing = drawing
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the canvas when the drawing binding changes (e.g., when cleared)
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Update the binding when user draws
            parent.drawing = canvasView.drawing
            parent.isDrawing = !canvasView.drawing.bounds.isEmpty
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var smokeCount = 5
        @State private var coCount = 3

        var body: some View {
            TenantAcknowledgementView(
                inspection: Inspection(
                    id: "3184947",
                    unitNumber: "041529",
                    siteCode: "909",
                    siteName: "Strawberry Mansion",
                    divisionCode: "SS",
                    address: "1940 N TAYLOR ST PHILADELPHIA PA 19121-2021",
                    tenantName: "LETTIE WARD",
                    tenantPhone: "484/239-7694",
                    tenantAvailability: true,
                    brSize: 2,
                    isHardwired: false,
                    status: .closed,
                    inspectorName: "CASTOR_USER5",
                    vehicleTagId: "Q",
                    startDate: "2025-05-02",
                    startTime: "08:30:00",
                    endDate: "2025-05-02",
                    endTime: "09:00:00",
                    submitTime: nil,
                    smokeDetectorsCount: 5,
                    coDetectorsCount: 3,
                    completionDate: "2025-05-02",
                    createdAt: "2025-01-15T10:00:00Z",
                    updatedAt: "2025-05-02T09:00:00Z"
                ),
                smokeDetectorsCount: $smokeCount,
                coDetectorsCount: $coCount
            )
        }
    }

    return PreviewWrapper()
}
