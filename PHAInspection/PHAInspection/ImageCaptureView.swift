//
//  ImageCaptureView.swift
//  PHAInspection
//
//  Image capture with camera and photo library
//

import SwiftUI
import PhotosUI

struct ImageCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection
    let itemId: String?
    let itemDescription: String?
    @Binding var images: [InspectionImageModel]

    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false

    private let imageService = ImageService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection

                ScrollView {
                    VStack(spacing: 24) {
                        // Item Info (if provided)
                        if let itemDesc = itemDescription {
                            itemInfoSection(itemDesc)
                        }

                        // Capture Options
                        captureOptionsSection

                        // Preview (if image selected)
                        if let image = selectedImage {
                            imagePreviewSection(image)
                        }

                        // Caption Input
                        if selectedImage != nil {
                            captionSection
                        }

                        // Upload Button
                        if selectedImage != nil {
                            uploadButton
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
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "7CB083"))
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Image uploaded successfully")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Photo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("SO #\(inspection.soNumber)")
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

    // MARK: - Item Info
    private func itemInfoSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspection Item")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            Text(description)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "111827"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Capture Options
    private var captureOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Choose Source")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Camera Button
                Button(action: { showCamera = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "7CB083"))

                        Text("Take Photo")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())

                // Photo Library Button
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "7CB083"))

                        Text("Photo Library")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Image Preview
    private func imagePreviewSection(_ image: UIImage) -> some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

            Button(action: {
                selectedImage = nil
                caption = ""
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                    Text("Remove")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(Color(hex: "DC2626"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "FEE2E2"))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Caption Section
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Caption (Optional)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "374151"))

            TextField("Describe the photo...", text: $caption, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
        }
    }

    // MARK: - Upload Button
    private var uploadButton: some View {
        Button(action: uploadImage) {
            HStack {
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 18))
                }

                Text(isUploading ? "Uploading..." : "Upload Photo")
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
        .disabled(isUploading)
    }

    // MARK: - Upload Image
    private func uploadImage() {
        guard let image = selectedImage else { return }

        isUploading = true

        Task {
            do {
                let imageDTO = try await imageService.uploadImage(
                    soNumber: inspection.soNumber,
                    itemId: itemId,
                    image: image,
                    caption: caption.isEmpty ? nil : caption
                )

                // Create local model
                let localImage = InspectionImageModel(dto: imageDTO, image: image)

                await MainActor.run {
                    self.images.append(localImage)
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
}

// MARK: - Image Picker (UIKit Bridge)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    ImageCaptureView(
        inspection: Inspection(
            id: "3184947",
            unitNumber: "041529",
            siteCode: "901",
            siteName: "Haddington",
            divisionCode: "D1",
            address: "123 Main St",
            tenantName: "John Doe",
            tenantPhone: nil,
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
        ),
        itemId: "K001",
        itemDescription: "Kitchen sink - leaks, damage",
        images: .constant([])
    )
}
