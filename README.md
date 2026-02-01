# PHA Inspection iPad Application

A comprehensive iPad application for Philadelphia Housing Authority (PHA) property inspections, built with React Native and AWS serverless architecture.

##  Overview

This application enables PHA inspectors to conduct property inspections efficiently on iPad devices, with offline capabilities, real-time sync, image capture, digital signatures, and AI-powered assistance through AWS Bedrock.

##  Features

- **Dashboard with Filtering**: Filter inspections by area, year, month, status
- **Inspection Management**: Create, update, and submit inspections
- **Multiple Inspection Areas**: Site exterior, rooms, kitchen, bathrooms, etc.
- **PMI Checklist**: Property Management Inspection items
- **Image Capture**: Take photos and attach to specific inspection items
- **Digital Signatures**: Tenant acknowledgement with signature capture
- **AWS Bedrock Chatbot**: AI assistant for inspection guidance
- **Offline Mode**: Work without internet and sync later
- **Real-time Sync**: Automatic synchronization when online

## Architecture

### Frontend
- **Framework**: React Native CLI (migrated from Expo)
- **State Management**: Redux Toolkit
- **UI Components**: React Native Paper
- **Navigation**: React Navigation
- **Offline Storage**: AsyncStorage + Redux Persist
- **Native iOS**: Full Xcode project with iPad-only configuration

### Backend
- **Infrastructure**: AWS Serverless (Lambda + API Gateway)
- **Database**: DynamoDB
- **File Storage**: S3
- **Authentication**: AWS Cognito
- **AI Assistant**: AWS Bedrock (Claude 3.5 Sonnet)

##  Project Structure

```
PHA-Inspection-App/
├── mobile/              # React Native iPad app
├── backend/             # AWS Lambda functions
├── infrastructure/      # Infrastructure as Code
├── docs/                # Documentation
└── README.md           # This file
```

##  Quick Start

### Prerequisites
- Node.js 20.x or higher
- AWS Account with IAM credentials
- Expo CLI
- iOS Simulator or iPad device

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd IpadOSapp
```

2. **Set up mobile app**
```bash
cd mobile
npm install
npm start
```

3. **Set up backend**
```bash
cd backend
npm install
npm run deploy:dev
```

For detailed setup instructions, see [docs/SETUP.md](docs/SETUP.md).

##  Documentation

- [CLAUDE.md](CLAUDE.md) - Complete development plan and architecture
- [docs/SETUP.md](docs/SETUP.md) - Detailed setup instructions
- [docs/API.md](docs/API.md) - API documentation (coming soon)

##  Technology Stack

### Mobile App
- React Native 0.74.5
- Expo 51.0.0
- Redux Toolkit 2.0.1
- React Navigation 6.x
- React Native Paper 5.x
- Axios for API calls
- React Hook Form for forms

### Backend
- AWS Lambda (Node.js 20.x)
- AWS DynamoDB
- AWS S3
- AWS API Gateway
- AWS Cognito
- AWS Bedrock (Claude 3.5 Sonnet)
- Serverless Framework

##  Key Screens

1. **Login** - AWS Cognito authentication
2. **Dashboard** - Overview with filters
3. **Inspection List** - Filterable list of inspections
4. **Inspection Detail** - Complete inspection form
5. **Inspection Areas** - Room-by-room checklists
6. **PMI Checklist** - Property management items
7. **Tenant Acknowledgement** - Digital signature
8. **Chatbot** - AI assistant for guidance

##  Development Status

### Phase 1: Foundation Setup 
- [x] Project structure created
- [x] React Native app initialized
- [x] Backend Lambda functions structure
- [x] AWS infrastructure configuration
- [x] Basic authentication flow
- [x] Redux store setup

### Phase 2: Authentication & Infrastructure (Next)
- [ ] AWS Cognito integration
- [ ] Login/logout screens
- [ ] Token management
- [ ] API Gateway setup

##  Security

- JWT-based authentication with AWS Cognito
- Encrypted data at rest (DynamoDB encryption)
- HTTPS/TLS for all API calls
- Pre-signed URLs for S3 uploads
- IAM least-privilege policies

##  Cost Estimation

Monthly AWS costs (estimated):
- DynamoDB: $50-100
- Lambda: $20-40
- S3: $25-50
- API Gateway: $3-10
- Cognito: $0 (free tier)
- Bedrock: $50-150 (usage-based)

**Total: ~$158-370/month**

##  Contributing

This is an internal project. For questions or issues:
1. Check the documentation
2. Review CloudWatch logs
3. Contact the development team

##  License

Proprietary - Philadelphia Housing Authority

---

**Version:** 1.0.0
**Last Updated:** 2025-12-08
**Status:** In Development - Phase 1 Complete
