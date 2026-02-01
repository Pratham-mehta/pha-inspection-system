//
//  ImageGalleryView.swift
//  PHAInspection
//
//  Image gallery for viewing and managing inspection photos
//

import SwiftUI

struct ImageGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let inspection: Inspection

    @State private var images: [InspectionImageModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showImageCapture = false
    @State private var selectedImage: InspectionImageModel?
    @State private var imageToDelete: InspectionImageModel?
    @State private var showDeleteAlert = false

    private let imageService = ImageService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection

                if isLoading {
                    loadingView
                } else if images.isEmpty {
                    emptyStateView
                } else {
                    // Image Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(images) { image in
                                imageCard(image)
                            }
                        }
                        .padding(24)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
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
            .sheet(isPresented: $showImageCapture) {
                ImageCaptureView(
                    inspection: inspection,
                    itemId: nil,
                    itemDescription: nil,
                    images: $images
                )
            }
            .sheet(item: $selectedImage) { image in
                ImageDetailView(image: image, onDelete: {
                    imageToDelete = image
                    showDeleteAlert = true
                    selectedImage = nil
                })
            }
            .alert("Delete Photo", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    imageToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let image = imageToDelete {
                        deleteImage(image)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this photo? This action cannot be undone.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
        .onAppear {
            loadImages()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Photos")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("\(images.count) photo\(images.count == 1 ? "" : "s") • SO #\(inspection.soNumber)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showImageCapture = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Add Photo")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "7CB083"))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)

            Divider()
        }
    }

    // MARK: - Image Card
    private func imageCard(_ image: InspectionImageModel) -> some View {
        Button(action: {
            selectedImage = image
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                // Caption (if exists)
                if let caption = image.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "374151"))
                        .lineLimit(2)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                }

                // Upload Status
                if image.isUploading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Uploading...")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "FEF3C7"))
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading photos...")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "D1D5DB"))

            VStack(spacing: 8) {
                Text("No Photos Yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))

                Text("Add photos to document inspection findings")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }

            Button(action: { showImageCapture = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add First Photo")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - Load Images
    private func loadImages() {
        isLoading = true

        Task {
            do {
                let imageDTOs = try await imageService.getImages(soNumber: inspection.soNumber)

                // In production, download actual images from URLs
                // For now, create placeholder images
                var loadedImages: [InspectionImageModel] = []

                for dto in imageDTOs {
                    // Create placeholder image (in production, download from dto.imageUrl)
                    let placeholderImage = createPlaceholderImage(text: "Photo #\(dto.id)")
                    let model = InspectionImageModel(dto: dto, image: placeholderImage)
                    loadedImages.append(model)
                }

                await MainActor.run {
                    self.images = loadedImages
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Delete Image
    private func deleteImage(_ image: InspectionImageModel) {
        Task {
            do {
                try await imageService.deleteImage(soNumber: inspection.soNumber, imageId: image.id)

                await MainActor.run {
                    self.images.removeAll { $0.id == image.id }
                    self.imageToDelete = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.imageToDelete = nil
                }
            }
        }
    }

    // MARK: - Create Placeholder Image
    private func createPlaceholderImage(text: String) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Background
            UIColor(Color(hex: "E5E7EB")).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor(Color(hex: "6B7280"))
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - Image Detail View
struct ImageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let image: InspectionImageModel
    let onDelete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Image
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: image.image)
                        .resizable()
                        .scaledToFit()
                }
                .background(Color.black)

                // Caption
                if let caption = image.caption, !caption.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Caption")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(caption)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "111827"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white)
                }

                Divider()

                // Delete Button
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                        Text("Delete Photo")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "DC2626"))
                    .cornerRadius(12)
                }
                .padding(20)
                .background(Color.white)
            }
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

// MARK: - Preview
#Preview {
    ImageGalleryView(
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
        )
    )
}
