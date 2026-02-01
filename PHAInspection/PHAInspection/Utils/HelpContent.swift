//
//  HelpContent.swift
//  PHAInspection
//
//  Centralized help content and onboarding steps
//

import Foundation
import SwiftUI

struct HelpContent {
    // MARK: - Dashboard Help
    static let dashboardSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to Dashboard",
            description: "This is your central hub for monitoring inspection activities. Let's take a quick tour of the key features.",
            targetFrame: CGRect(x: 100, y: 150, width: 300, height: 100),
            position: .bottom
        ),
        OnboardingStep(
            title: "Status Summary Cards",
            description: "These cards show your inspection counts:\n• New: Inspections waiting to be started\n• In Progress: Currently active inspections\n• Closed: Completed inspections\n• Total: All inspections combined",
            targetFrame: CGRect(x: 50, y: 340, width: 850, height: 150),
            position: .bottom
        ),
        OnboardingStep(
            title: "Site Overview",
            description: "Each site card shows:\n• Site name and code\n• Total inspection count (right side)\n• Breakdown by status (New, In Progress, Closed)\n\nUse this to see which sites need attention.",
            targetFrame: CGRect(x: 50, y: 540, width: 870, height: 160),
            position: .bottom
        ),
        OnboardingStep(
            title: "Filter Your Data",
            description: "Use these dropdowns to filter inspections by:\n• Area (SS, CS, AMPB, PAPMC)\n• Year (2004-2025)\n• Month (January-December)\n\nFiltering updates all counts instantly.",
            targetFrame: CGRect(x: 50, y: 260, width: 400, height: 40),
            position: .bottom
        ),
        OnboardingStep(
            title: "Refresh Data",
            description: "Tap this button to refresh dashboard data and get the latest inspection counts from the server.",
            targetFrame: CGRect(x: 820, y: 205, width: 90, height: 35),
            position: .left
        )
    ]

    // MARK: - Inspection List Help
    static let inspectionListSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to Inspections",
            description: "This is your inspection list where you can view all assigned inspections and start working on them.",
            targetFrame: CGRect(x: 100, y: 150, width: 300, height: 100),
            position: .bottom
        ),
        OnboardingStep(
            title: "Status Indicators",
            description: "Each inspection has a colored status indicator:\n• Blue dot = New inspection (not started)\n• Orange dot = In Progress (currently working)\n• Green checkmark = Closed (completed)",
            targetFrame: CGRect(x: 50, y: 340, width: 870, height: 120),
            position: .bottom
        ),
        OnboardingStep(
            title: "Inspection Details",
            description: "Each row shows:\n• SO (Service Order) Number\n• Site name and unit number\n• Tenant name\n• Inspection date\n• Completion status\n\nTap any row to view full details and start the inspection.",
            targetFrame: CGRect(x: 50, y: 340, width: 870, height: 120),
            position: .bottom
        ),
        OnboardingStep(
            title: "Filter Your Inspections",
            description: "Use these filters to narrow down your list:\n• Status: Show only New, In Progress, or Closed\n• Area: Filter by geographic area\n• Site: Filter by specific site code\n\nFiltering helps you focus on what needs attention.",
            targetFrame: CGRect(x: 50, y: 240, width: 500, height: 40),
            position: .bottom
        )
    ]

    static let inspectionListHelp = """
    Inspection List Guide

    Status Indicators:
    • Blue dot = New inspection
    • Orange dot = In Progress
    • Green dot with checkmark = Closed

    Filters:
    • Status: Filter by New, In Progress, or Closed
    • Area: Filter by geographic area (SS, CS, etc.)
    • Site: Filter by specific site code

    Tap any inspection to view full details and start working on it.
    """

    // MARK: - Inspection Detail Help
    static let inspectionDetailHelp = """
    Inspection Detail Guide

    Sections:
    • Unit Information: Property details, bedrooms, hardwired status
    • Tenant Information: Contact details and availability
    • Inspection Details: Inspector assigned, vehicle tag
    • Schedule: Start/end dates and times
    • Detectors: Count of smoke and CO detectors

    Actions:
    • Save: Update inspection details
    • Start Checklist: Begin room-by-room inspection
    • Submit: Complete and close the inspection

    Note: You cannot edit closed inspections.
    """

    // MARK: - Glossary
    static let glossary: [String: String] = [
        "SO Number": "Service Order Number - Unique identifier for each inspection",
        "Site Code": "3-digit code identifying the property location (e.g., 901 = Haddington)",
        "Division Code": "Geographic division assignment (D1, D2, D3, D4)",
        "Hardwired": "Indicates if smoke detectors are wired into electrical system vs battery-powered",
        "Tenant Availability": "Whether tenant will be present during inspection",
        "Vehicle Tag": "Inspector's vehicle identification letter (A-Z)",
        "BR Size": "Number of bedrooms in the unit",
        "PMI": "Preventive Maintenance Inspection",
        "Def": "Deficiency found during inspection requiring repair",
        "RRP": "Renovation, Repair & Painting - Lead-safe work requirements"
    ]

    // MARK: - Help Sheet Content
    static func helpSheetContent(for screen: String) -> String {
        switch screen {
        case "Dashboard":
            return """
            Dashboard Overview

            Your dashboard provides a real-time snapshot of inspection activities:

            Status Cards
            • New: Inspections assigned but not started
            • In Progress: Active inspections in the field
            • Closed: Completed inspections
            • Total: Sum of all inspections

            Sites Overview
            Each site card shows inspection counts broken down by status. The total count appears on the right side.

            Filters
            • Area: Geographic region (SS=Scattered Sites, CS=Conventional Sites, AMPB=Asset Management PHA Broad, PAPMC=PHA Asset Management Consulting)
            • Year/Month: Time period for inspection data

            Tip: Tap "Refresh" to get the latest data from the server.
            """
        case "Inspections":
            return inspectionListHelp
        case "InspectionDetail":
            return inspectionDetailHelp
        default:
            return "Help content not available for this screen."
        }
    }
}
