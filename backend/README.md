# PHA Inspection Backend

Spring Boot REST API for Philadelphia Housing Authority Inspection System

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- DynamoDB (local or AWS)

## Project Structure

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/pha/inspection/
│   │   │   ├── BackendApplication.java
│   │   │   ├── config/
│   │   │   │   ├── DynamoDBConfig.java
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   └── SwaggerConfig.java
│   │   │   ├── controller/
│   │   │   │   └── HealthController.java
│   │   │   ├── service/
│   │   │   ├── repository/
│   │   │   ├── model/
│   │   │   │   ├── dto/
│   │   │   │   ├── entity/
│   │   │   │   └── enums/
│   │   │   ├── security/
│   │   │   ├── exception/
│   │   │   └── util/
│   │   └── resources/
│   │       └── application.yml
│   └── test/
└── pom.xml
```

## Running the Application

### 1. Build the project

```bash
cd backend
mvn clean install
```

### 2. Run the application

```bash
mvn spring-boot:run
```

Or run the JAR file:

```bash
java -jar target/inspection-backend-0.0.1-SNAPSHOT.jar
```

## Access Points

- **API Base URL**: `http://localhost:8080/api`
- **Health Check**: `http://localhost:8080/api/health`
- **Swagger UI**: `http://localhost:8080/api/swagger-ui.html`
- **API Docs**: `http://localhost:8080/api/api-docs`
- **Actuator Health**: `http://localhost:8080/api/actuator/health`

## Environment Variables

Set these environment variables before running:

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=us-east-1
export JWT_SECRET=your_jwt_secret_key
export AWS_DYNAMODB_ENDPOINT=http://localhost:8000  # For DynamoDB Local
```

## DynamoDB Local (for development)

### Using Docker

```bash
docker run -p 8000:8000 amazon/dynamodb-local
```

### Using JAR

```bash
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
```

## Development Phases

- [x] **Phase 1**: Backend Foundation - Project setup complete
- [ ] **Phase 2**: Authentication & Security
- [ ] **Phase 3**: Dashboard API
- [ ] **Phase 4**: Inspection Management
- [ ] **Phase 5**: Inspection Areas & Items
- [ ] **Phase 6**: Response Management
- [ ] **Phase 7**: PMI Checklist
- [ ] **Phase 8**: Testing & Documentation
- [ ] **Phase 9**: React Native Frontend
- [ ] **Phase 10**: Deployment

## Current Status

✅ Spring Boot project initialized
✅ Maven dependencies configured
✅ DynamoDB configuration ready
✅ Swagger UI configured
✅ Health check endpoint created

## Next Steps

1. Test the application startup
2. Verify Swagger UI is accessible
3. Begin Phase 2: Implement JWT authentication
