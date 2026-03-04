# PHA Inspection System

A comprehensive inspection management system for Philadelphia Housing Authority (PHA), consisting of a Spring Boot REST API backend, an AWS DynamoDB database, a native SwiftUI iPad application for field inspectors, and a React web admin portal for supervisors.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Spring Boot Backend (Port 8080)                 │
│              26 REST API Endpoints + JWT Auth                │
│               AWS DynamoDB (Single-table design)             │
└──────────────────────────┬──────────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             │                           │
 ┌───────────▼──────────┐   ┌───────────▼──────────┐
 │  iPad App (SwiftUI)  │   │   Web Admin (React)  │
 │  Field Inspectors    │   │  Supervisors/Admins  │
 │  Port: Xcode/Device  │   │  Port: 5173           │
 └──────────────────────┘   └──────────────────────┘
```

---

## Technology Stack

### Backend
- **Framework**: Spring Boot 3.2.x (Java 17)
- **Database**: AWS DynamoDB (single-table design, 3 GSI indexes)
- **Authentication**: Spring Security + JWT (HS512)
- **API Docs**: Swagger UI / OpenAPI 3.0
- **Build Tool**: Maven

### iPad App
- **Framework**: SwiftUI (iPadOS 15+)
- **Signature Capture**: PencilKit
- **API Client**: URLSession (native)
- **State Management**: @StateObject / ObservableObject

### Web Admin
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **UI Library**: Material-UI (MUI) v5
- **State Management**: Zustand + React Query
- **API Client**: Axios

---

## Project Structure

```
IpadOSapp/
├── backend/                  # Spring Boot REST API
│   ├── src/main/java/com/pha/inspection/
│   │   ├── controller/       # 9 REST controllers
│   │   ├── service/          # 11 business logic services
│   │   ├── repository/       # DynamoDB repositories
│   │   ├── model/            # DTOs (23) and entities (11)
│   │   ├── security/         # JWT token provider & filter
│   │   └── config/           # DynamoDB, Security, Swagger configs
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   └── application-prod.yml
│   └── pom.xml
│
├── PHAInspection/            # SwiftUI iPad Xcode project
│   └── PHAInspection/
│       ├── *View.swift       # 12 views (login, dashboard, checklist, etc.)
│       ├── Models/           # 7 Codable model files
│       ├── Services/         # 10 service classes with JWT auth
│       └── Utils/            # Colors, help system, onboarding
│
├── web-admin/                # React + TypeScript admin portal
│   └── src/
│       ├── pages/            # LoginPage, DashboardPage
│       ├── services/         # API service classes
│       ├── store/            # Zustand auth store
│       └── types/            # TypeScript type definitions
│
├── ios-app/                  # Legacy Swift reference files
├── infrastructure/           # Infrastructure as Code (future)
├── docs/                     # Documentation (future)
├── start-all.sh              # Starts backend + web admin
└── restart-backend.sh        # Restarts backend server
```

---

## API Endpoints (26 total)

### Authentication
- `POST /auth/login` — Inspector login, returns JWT token
- `POST /auth/create-inspector` — Create new inspector account

### Dashboard
- `GET /dashboard/summary` — Aggregated statistics with filters (area, year, month, site)

### Inspections
- `GET /inspections` — Paginated list with filters (status, area, site)
- `GET /inspections/{soNumber}` — Full inspection details
- `POST /inspections` — Create new inspection
- `PUT /inspections/{soNumber}` — Update inspection (partial)
- `POST /inspections/{soNumber}/submit` — Submit and close inspection

### Inspection Areas & Items
- `GET /inspections/areas` — 8 inspection areas
- `GET /inspections/areas/items?areaName={name}` — 54 items across all areas

### Inspection Responses
- `POST /inspections/{soNumber}/responses` — Save OK/NA/Def response
- `GET /inspections/{soNumber}/responses` — List all responses
- `GET /inspections/{soNumber}/responses/{itemId}` — Single response
- `DELETE /inspections/{soNumber}/responses/{itemId}` — Delete response

### PMI Checklist
- `GET /pmi/categories` — 8 PMI categories
- `GET /pmi/categories/{categoryId}/items` — 32 items across all categories
- `POST /pmi/inspections/{soNumber}/responses` — Save PMI response
- `GET /pmi/inspections/{soNumber}/responses` — List all PMI responses
- `GET /pmi/inspections/{soNumber}/responses/{itemId}` — Single PMI response
- `DELETE /pmi/inspections/{soNumber}/responses/{itemId}` — Delete PMI response

### Image Management
- `POST /inspections/{soNumber}/images/upload` — Upload photo (Base64)
- `GET /inspections/{soNumber}/images` — List all photos
- `GET /inspections/{soNumber}/images/{imageId}` — Single photo
- `DELETE /inspections/{soNumber}/images/{imageId}` — Delete photo

### Signature Management
- `POST /inspections/{soNumber}/signatures/upload` — Upload signature (Base64 PNG)
- `GET /inspections/{soNumber}/signatures` — List signatures
- `GET /inspections/{soNumber}/signatures/{signatureId}` — Single signature
- `DELETE /inspections/{soNumber}/signatures/{signatureId}` — Delete signature

### Health
- `GET /health` — Service status
- `GET /actuator/health` — Spring Boot actuator health

> All endpoints except `/auth/**`, `/health`, and `/actuator/**` require a `Bearer` JWT token.

---

## Running the Application

### Backend (Spring Boot)

```bash
cd backend

# Build
mvn clean package -DskipTests

# Run
java -jar target/inspection-backend-0.0.1-SNAPSHOT.jar

# Or with Maven
mvn spring-boot:run
```

Access points:
- API Base: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui.html`
- Health Check: `http://localhost:8080/api/health`

Create a test inspector and login:
```bash
# Create inspector
curl -X POST "http://localhost:8080/api/auth/create-inspector?inspectorId=TEST001&name=Test%20Inspector&password=test123&vehicleTagId=T1"

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"inspectorId":"TEST001","password":"test123"}'
```

### iPad App (Xcode)

```bash
cd PHAInspection
open PHAInspection.xcodeproj
```

1. Select an iPad simulator (or physical iPad) in the Xcode toolbar
2. Verify `Services/APIConfig.swift` has the correct base URL:
   - Simulator: `http://localhost:8080/api`
   - Physical iPad: `http://<YOUR_MAC_IP>:8080/api`
3. Press `Cmd + R` to build and run
4. Login with `TEST001` / `test123`

### Web Admin (React)

```bash
cd web-admin
npm install   # first time only
npm run dev
```

Access at `http://localhost:5173`. Login with the same inspector credentials.

### Start Everything at Once

```bash
./start-all.sh
```

Starts the backend on port 8080 and web admin on port 5173.

Stop servers:
```bash
lsof -ti:8080 | xargs kill -9   # backend
lsof -ti:5173 | xargs kill -9   # web admin
```

---

## DynamoDB Schema

Single-table design with composite keys and 3 Global Secondary Indexes.

**Table**: `pha-inspections`
- Partition Key: `PK` (String)
- Sort Key: `SK` (String)

| Entity | PK | SK |
|---|---|---|
| Inspector | `INSPECTOR#{id}` | `METADATA` |
| Inspection | `INSPECTION#{soNumber}` | `METADATA` |
| Site | `SITE#{code}` | `METADATA` |
| Area | `AREA#{code}` | `METADATA` |
| Unit | `UNIT#{number}` | `SITE#{code}` |
| Response | `INSPECTION#{soNumber}` | `RESPONSE#{itemId}` |
| PMI Response | `INSPECTION#{soNumber}` | `PMI_RESPONSE#{itemId}` |

**GSI1** (entity relationships): `GSI1PK` + `GSI1SK`
**GSI2** (status & date filtering): `GSI2PK` + `GSI2SK`
**GSI3** (inspector assignment): `GSI3PK` + `GSI3SK`

---

## iPad App Features

| Feature | Details |
|---|---|
| Authentication | Login/signup with JWT token persistence |
| Dashboard | Site summaries filtered by area, year, month |
| Inspection List | Paginated list with status/area/site filters |
| Inspection Detail | Full form with edit, save, and submit |
| Inspection Checklist | 8 areas, 54 items — OK / NA / Def responses |
| Deficiency Form | Scope of work, service ID, activity code, material, flags |
| PMI Checklist | 8 categories, 32 items with notes and completion tracking |
| Image Capture | Camera + photo library, compression, caption, gallery |
| Image Gallery | 3-column grid, full-screen viewer with zoom/pan, delete |
| Signature Capture | PencilKit canvas, read-only display if already signed |
| Tenant Acknowledgement | Legal text, detector counts, signature persistence |
| Help System | Onboarding tour (5 steps), glossary, help button on all screens |

---

## Development Status

| Phase | Description | Status |
|---|---|---|
| 1 | Spring Boot foundation + DynamoDB setup | Complete |
| 2 | JWT authentication | Complete |
| 3 | Dashboard API | Complete |
| 4 | Inspection CRUD | Complete |
| 5 | Inspection areas & items | Complete |
| 6 | Inspection response management | Complete |
| 7 | PMI checklist | Complete |
| 8 | API testing & documentation | Complete |
| 9 | SwiftUI iPad app (all features) | Complete |
| 10 | DynamoDB migration (in-memory → persistent) | In Progress |
| 11 | Web admin portal expansion | Planned |
| 12 | Production deployment (AWS EC2 / ECS) | Planned |

### Phase 10 — DynamoDB Migration Progress

| Component | Storage | Status |
|---|---|---|
| InspectorRepository | DynamoDB | Migrated |
| InspectionRepository | DynamoDB | Migrated |
| ResponseService | In-Memory | Pending |
| PMIResponseService | In-Memory | Pending |
| AreaService | In-Memory | Pending |
| PMIService | In-Memory | Pending |
| ImageService | In-Memory | Pending |
| SignatureService | In-Memory | Pending |
| DashboardService | Mock data | Pending |

---

## Security

- Passwords hashed with BCrypt
- JWT tokens signed with HS512 (512-bit secret)
- 24-hour token expiration
- Spring Security protects all non-public routes
- CORS configured for web admin origin
- Input validation on all write endpoints

---

## Environment Variables

```bash
# backend/.env
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
JWT_SECRET=...          # Must be >= 512 bits for HS512

# For DynamoDB Local (development)
AWS_DYNAMODB_ENDPOINT=http://localhost:8000
```

---

## Test Scripts

All scripts are in `backend/`:

```bash
./test-all-endpoints.sh       # All 26 endpoints
./test-auth-flow.sh           # Authentication flow
./test-image-endpoints.sh     # Image upload/download
./test-signature-endpoints.sh # Signature management
./test-pmi-complete.sh        # PMI checklist
```

---

## Documentation

| File | Contents |
|---|---|
| `CLAUDE.md` | Complete development plan, schema, API reference |
| `TESTING_GUIDE.md` | Swagger UI and curl testing guide |
| `DYNAMODB_MIGRATION_GUIDE.md` | Steps to migrate from in-memory to DynamoDB |
| `WEB_ADMIN_COMPLETE.md` | Web admin portal documentation |
| `IMAGE_CAPTURE_SUMMARY.md` | Image capture system documentation |
| `PMI_IMPLEMENTATION_SUMMARY.md` | PMI checklist implementation details |
| `PHASE_9_STATUS.md` | Phase 9 (iPad app) completion summary |
| `START_SERVERS.md` | Server startup instructions |
| `backend/README.md` | Backend-specific setup and notes |

---

**Version**: 2.0.0
**Last Updated**: 2026-03-03
**Status**: Phase 9 Complete — Phase 10 (DynamoDB Migration) In Progress
**License**: Proprietary — Philadelphia Housing Authority
