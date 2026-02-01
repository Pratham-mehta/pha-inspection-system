//
//  OnboardingOverlay.swift
//  PHAInspection
//
//  Welcome tour overlay for first-time users
//

import SwiftUI

struct OnboardingStep {
    let title: String
    let description: String
    let targetFrame: CGRect
    let position: PopoverPosition

    enum PopoverPosition {
        case top, bottom, left, right
    }
}

struct OnboardingOverlay: View {
    @Binding var isPresented: Bool
    let steps: [OnboardingStep]

    @State private var currentStep = 0
    @Namespace private var animation

    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Allow dismissing by tapping backdrop
                }

            // Spotlight effect (clear area around target)
            if currentStep < steps.count {
                let step = steps[currentStep]

                SpotlightShape(cutout: step.targetFrame)
                    .fill(Color.clear)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Info card
                VStack(spacing: 0) {
                    infoCard(for: step)
                        .transition(.scale.combined(with: .opacity))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignmentFor(step.position))
                .padding(40)
            }
        }
    }

    // MARK: - Info Card
    private func infoCard(for step: OnboardingStep) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step indicator
            HStack {
                Text("Step \(currentStep + 1) of \(steps.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "7CB083"))

                Spacer()

                Button(action: { isPresented = false }) {
                    Text("Skip Tour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Title
            Text(step.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            // Description
            Text(step.description)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "6B7280"))
                .fixedSize(horizontal: false, vertical: true)

            // Navigation buttons
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button(action: previousStep) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "7CB083"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: "7CB083").opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Spacer()

                Button(action: nextStep) {
                    HStack {
                        Text(currentStep == steps.count - 1 ? "Done" : "Next")
                        if currentStep < steps.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
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
                    .cornerRadius(8)
                    .shadow(color: Color(hex: "7CB083").opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 400)
    }

    // MARK: - Spotlight Shape
    struct SpotlightShape: Shape {
        let cutout: CGRect

        func path(in rect: CGRect) -> Path {
            var path = Path(rect)
            path.addRoundedRect(in: cutout.insetBy(dx: -8, dy: -8), cornerSize: CGSize(width: 12, height: 12))
            return path
        }
    }

    // MARK: - Helper Functions
    private func alignmentFor(_ position: OnboardingStep.PopoverPosition) -> Alignment {
        switch position {
        case .top: return .bottom
        case .bottom: return .top
        case .left: return .trailing
        case .right: return .leading
        }
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            isPresented = false
        }
    }

    private func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()

        OnboardingOverlay(
            isPresented: .constant(true),
            steps: [
                OnboardingStep(
                    title: "Status Cards",
                    description: "Track inspection counts by status: New inspections to start, In Progress work, and Closed completed inspections.",
                    targetFrame: CGRect(x: 50, y: 300, width: 200, height: 150),
                    position: .bottom
                )
            ]
        )
    }
}
