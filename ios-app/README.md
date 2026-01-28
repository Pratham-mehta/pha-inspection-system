# PHA Inspection iPad App - Swift/SwiftUI

## Overview
Native iPad application for Philadelphia Housing Authority (PHA) inspection management system.

**Development Approach**: Hybrid workflow using VS Code (Claude Code) + Xcode
- **VS Code**: Swift logic, models, networking, business layer (AI-assisted)
- **Xcode**: SwiftUI UI, building, testing, App Store submission

---

## Project Structure

```
ios-app/
├── Models/                     # Data models (✅ Created in VS Code)
│   ├── Inspector.swift
│   ├── Inspection.swift
│   ├── Dashboard.swift
│   ├── InspectionArea.swift
│   ├── InspectionResponse.swift
│   └── PMI.swift
│
├── Services/                   # Networking layer (✅ Created in VS Code)
│   ├── APIConfig.swift         # API endpoints configuration
│   ├── NetworkError.swift      # Error handling
│   ├── APIService.swift        # Core URLSession service
│   ├── AuthManager.swift       # JWT authentication manager
│   ├── InspectionService.swift # Inspection API calls
│   ├── DashboardService.swift  # Dashboard API calls
│   ├── InspectionAreaService.swift
│   ├── ResponseService.swift
│   └── PMIService.swift
│
├── Views/                      # SwiftUI views (❌ Create in Xcode)
│   ├── Authentication/
│   ├── Dashboard/
│   ├── Inspections/
│   └── PMI/
│
├── ViewModels/                 # Business logic (⚠️ Create as needed)
└── Utils/                      # Helper utilities
```

---

## Step 1: Create Xcode Project ✅ COMPLETED

1. ✅ Open Xcode
2. ✅ File → New → Project
3. ✅ Select **App** template under iOS
4. ✅ Configure:
   - Product Name: `PHAInspection`
   - Team: Pratham Mehta (Personal Team)
   - Organization Identifier: `io.github.pratham-mehta`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Testing: None
   - Storage: None
5. ✅ Created at: `/Users/prathammehta/Desktop/Pratham/IpadOSapp/PHAInspection/`
6. Select iPad only:
   - Go to target settings → General → Deployment Info
   - Uncheck iPhone, keep only iPad
   - Minimum iOS version: 15.0+

---

## Step 2: Add Swift Files to Xcode Project ⏳ IN PROGRESS

### Files to Copy from `/ios-app/`:

**Models folder (6 files)**:
- Inspector.swift
- Inspection.swift
- Dashboard.swift
- InspectionArea.swift
- InspectionResponse.swift
- PMI.swift

**Services folder (9 files)**:
- APIConfig.swift
- NetworkError.swift
- APIService.swift
- AuthManager.swift
- InspectionService.swift
- DashboardService.swift
- InspectionAreaService.swift
- ResponseService.swift
- PMIService.swift

### Method 1: Drag and Drop (Recommended)
1. Open Finder: `/Users/prathammehta/Desktop/Pratham/IpadOSapp/ios-app/Models/`
2. Select **all 6 Swift files**
3. **Drag them** into Xcode project navigator (drop on "PHAInspection" folder)
4. In popup dialog, check:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: PHAInspection**
5. Click "Finish"
6. Repeat for `Services/` folder (all 9 files)

### Method 2: Add Files
1. Right-click "PHAInspection" in Xcode navigator
2. "Add Files to PHAInspection..."
3. Navigate to `/Users/prathammehta/Desktop/Pratham/IpadOSapp/ios-app/`
4. Select `Models` folder
5. Check same options as Method 1
6. Click "Add"
7. Repeat for `Services/` folder

---

## Step 3: Verify Files in Xcode

After adding files, your Xcode project navigator should look like:

```
PHAInspection/
├── PHAInspectionApp.swift
├── ContentView.swift
├── Models/
│   ├── Inspector.swift
│   ├── Inspection.swift
│   ├── Dashboard.swift
│   ├── InspectionArea.swift
│   ├── InspectionResponse.swift
│   └── PMI.swift
├── Services/
│   ├── APIConfig.swift
│   ├── NetworkError.swift
│   ├── APIService.swift
│   ├── AuthManager.swift
│   ├── InspectionService.swift
│   ├── DashboardService.swift
│   ├── InspectionAreaService.swift
│   ├── ResponseService.swift
│   └── PMIService.swift
└── Assets.xcassets
```

---

## Step 4: Build to Check for Errors

1. In Xcode: **Command + B** to build
2. Fix any errors (should be none if files added correctly)
3. If successful, you'll see "Build Succeeded"

---

## Step 5: Create SwiftUI Views (In Xcode)

### 5.1 Login View Example

Create new file in Xcode:
1. Right-click on project → New Group → "Views"
2. Right-click "Views" → New Group → "Authentication"
3. Right-click "Authentication" → New File → SwiftUI View
4. Name: `LoginView.swift`

```swift
import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var inspectorId = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("PHA Inspection")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Inspector ID", text: $inspectorId)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || inspectorId.isEmpty || password.isEmpty)
        }
        .padding()
        .frame(maxWidth: 400)
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await authManager.login(
                    inspectorId: inspectorId,
                    password: password
                )
                // Navigation handled by @Published isAuthenticated
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
```

### 5.2 Update Main App File

Replace `PHAInspectionApp.swift`:

```swift
import SwiftUI

@main
struct PHAInspectionApp: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()  // Main app view
            } else {
                LoginView()
            }
        }
    }
}
```

---

## Step 6: Configure for iPad

1. Select project in navigator
2. Select target → General
3. Deployment Info:
   - **Device Orientation**: Check all iPad orientations
   - **Requires Full Screen**: Uncheck (allow Split View/Slide Over)
4. Add iPad icons to Assets.xcassets

---

## Step 7: Run on iPad Simulator

1. Select iPad simulator from device menu (e.g., "iPad Pro 12.9-inch")
2. Press **Command + R** to run
3. Test login with backend running at `http://localhost:8080/api`

---

## Step 8: Test API Integration

Before running app, ensure backend is running:

```bash
cd /Users/prathammehta/Desktop/Pratham/IpadOSapp/backend
mvn spring-boot:run
```

Then in app:
- Login with: `INS001` / `password123`
- Verify JWT token is saved
- Test API calls to backend

---

## Development Workflow

### For Swift Logic/Models (VS Code with Claude Code):
1. Open VS Code at: `/Users/prathammehta/Desktop/Pratham/IpadOSapp/ios-app/`
2. Create/modify Swift files in `Models/` or `Services/`
3. Claude Code assists with Swift code
4. Save files
5. Files are already in Xcode (same directory)
6. Xcode will auto-detect changes

### For SwiftUI UI (Xcode):
1. Open Xcode project
2. Create SwiftUI views in Xcode
3. Use SwiftUI Canvas for live preview
4. Build and run on simulator

---

## API Configuration

Backend URL is configured in `Services/APIConfig.swift`:
- **Development**: `http://localhost:8080/api`
- **Production**: Update before App Store release

To change:
```swift
#if DEBUG
static let baseURL = "http://localhost:8080/api"
#else
static let baseURL = "https://your-production-server.com/api"
#endif
```

---

## Authentication Flow

1. User enters credentials in `LoginView`
2. `AuthManager.login()` called
3. API call to `POST /auth/login`
4. JWT token stored in UserDefaults
5. `@Published isAuthenticated` triggers UI update
6. App shows `ContentView` (main app)

All subsequent API calls include JWT token in headers.

---

## Next Steps

1. ✅ Models created (in VS Code)
2. ✅ Services created (in VS Code)
3. ❌ Create SwiftUI views (in Xcode):
   - LoginView
   - DashboardView
   - InspectionListView
   - InspectionDetailView
   - InspectionChecklistView
   - ResponseFormView
   - PMIChecklistView
4. ❌ Add Core Data for offline storage
5. ❌ Implement image capture (camera/photos)
6. ❌ Add signature capture with PencilKit
7. ❌ Test end-to-end flow
8. ❌ Prepare for App Store submission

---

## Troubleshooting

### "Cannot find APIService in scope"
- Ensure all files in `Services/` are added to Xcode target
- Clean build folder: **Command + Shift + K**
- Rebuild: **Command + B**

### "No such module 'Foundation'"
- This shouldn't happen, but if it does: restart Xcode

### Backend connection fails
- Ensure backend is running on port 8080
- Check `APIConfig.baseURL` matches backend URL
- For iOS simulator, use `http://localhost:8080` (not 127.0.0.1)

---

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [URLSession Guide](https://developer.apple.com/documentation/foundation/urlsession)
- [Async/Await in Swift](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Core Data Tutorial](https://developer.apple.com/documentation/coredata)

---

**Ready to build the UI in Xcode!** 🚀
