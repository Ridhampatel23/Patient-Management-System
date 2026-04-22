
# Patient Management System

A cloud-native **microservices-based Patient Management System** built with **Java 21 + Spring Boot**, featuring JWT authentication, an API gateway, inter-service communication via **gRPC** and **Kafka**, and infrastructure-as-code with **AWS CDK / LocalStack**.

---

## 🏗️ Architecture

```
                         ┌────────────────────┐
                         │    API Gateway     │
                         │  (JWT validation)  │
                         └─────────┬──────────┘
                                   │ REST
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
┌────────────────┐        ┌────────────────┐         ┌─────────────────┐
│  Auth Service  │        │ Patient Service│         │Analytics Service│
│  (JWT issuer)  │        │    (REST API)  │         │ (Kafka consumer)│
└────────────────┘        └───────┬────────┘         └────────▲────────┘
                          gRPC │          │ Kafka              │
                               ▼          └────────────────────┘
                       ┌────────────────┐
                       │ Billing Service│
                       │     (gRPC)     │
                       └────────────────┘
```

---

## 📦 Services

| Service | Description | Tech |
|---|---|---|
| **api-gateway** | Central entry point, routes requests, validates JWTs | Spring Cloud Gateway |
| **auth-service** | Issues and validates JWTs for user login | Spring Security + JPA |
| **patient-service** | CRUD for patients; publishes events to Kafka; calls billing via gRPC | Spring Boot, JPA, Kafka Producer, gRPC Client |
| **billing-service** | Creates billing accounts, exposed via gRPC | Spring Boot + gRPC Server |
| **analytics-service** | Consumes patient events from Kafka | Spring Boot + Kafka Consumer |
| **infrastructure** | AWS CDK stack for deploying services locally via LocalStack | AWS CDK (Java) |
| **integration-tests** | End-to-end integration test suite | REST-assured / JUnit |

---

## 🛠️ Tech Stack

- **Language:** Java 21
- **Framework:** Spring Boot 3
- **Build Tool:** Maven
- **Messaging:** Apache Kafka
- **RPC:** gRPC + Protocol Buffers
- **Auth:** JWT (JSON Web Tokens)
- **Database:** PostgreSQL (via JPA / Hibernate), H2 for local dev
- **Containerization:** Docker
- **Infrastructure:** AWS CDK + LocalStack
- **Testing:** JUnit 5, REST-assured

---

## 🚀 Getting Started

### Prerequisites

- Java 21+
- Maven 3.9+
- Docker & Docker Compose
- (Optional) LocalStack CLI for simulating AWS locally

### Clone

```bash
git clone https://github.com/Ridhampatel23/Patient-Management-System.git
cd Patient-Management-System
```

### Build all services

Each service is a standalone Maven project. Build them individually:

```bash
cd patient-service && ./mvnw clean package
cd ../auth-service && ./mvnw clean package
cd ../billing-service && ./mvnw clean package
cd ../analytics-service && ./mvnw clean package
cd ../api-gateway && ./mvnw clean package
```

### Run with Docker

Each service includes a `Dockerfile`. Build and run:

```bash
docker build -t patient-service ./patient-service
docker run -p 4000:4000 patient-service
```

### Run infrastructure on LocalStack

```bash
cd infrastructure
./mvnw compile
cdklocal bootstrap
cdklocal deploy
```

---

## 🔌 API Endpoints

HTTP test files are provided under `api-requests/` and `grpc-requests/`.

### Auth Service
- `POST /login` — authenticate and receive a JWT
- `GET /validate` — validate an existing token

### Patient Service (protected by JWT via API Gateway)
- `GET /patients` — list all patients
- `POST /patients` — create a new patient
- `PUT /patients/{id}` — update a patient
- `DELETE /patients/{id}` — delete a patient

### Billing Service (gRPC)
- `CreateBillingAccount` — creates a billing account for a new patient

---

## 📡 Event Flow

1. A client logs in via **auth-service** → receives a JWT.
2. Client calls **api-gateway** with the JWT; the gateway validates it.
3. When a patient is created in **patient-service**:
   - A gRPC call is made to **billing-service** to create a billing account.
   - A `PatientEvent` is published to **Kafka**.
4. **analytics-service** consumes the `PatientEvent` from Kafka for downstream analytics.

---

## 🧪 Testing

Run integration tests:

```bash
cd integration-tests
./mvnw test
```

---

## 📁 Project Structure

```
.
├── api-gateway/          # Spring Cloud Gateway + JWT filter
├── auth-service/         # JWT issuance & validation
├── patient-service/      # Patient REST API + Kafka producer + gRPC client
├── billing-service/      # gRPC server for billing
├── analytics-service/    # Kafka consumer for analytics
├── infrastructure/       # AWS CDK stack (LocalStack)
├── integration-tests/    # End-to-end tests
├── api-requests/         # .http files for manual REST testing
└── grpc-requests/        # .http files for gRPC testing
```

---

## 📝 License

This project is provided as-is for educational purposes.

---

## 👤 Author

**Ridham Patel** — [@Ridhampatel23](https://github.com/Ridhampatel23)
