//
//  ContentView.swift
//  PHAInspection
//
//  Created by Pratham Mehta on 12/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { 
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            InspectionListView()
                .tabItem {
                    Label("Inspections", systemImage: "doc.text.fill")
                }
                .tag(1)
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
