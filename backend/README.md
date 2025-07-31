# 📁 File Upload Lookup Platform

A full-stack platform for uploading file metadata and querying it via a user-friendly interface. The backend is built with **Spring Boot** and **AWS (DynamoDB + S3)**, with a **React** frontend (planned) for file uploads and search functionality.

![Java](https://img.shields.io/badge/Backend-Java_17-blue.svg)
![Spring Boot](https://img.shields.io/badge/Spring--Boot-3.3.x-green)
![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)

---

## 🚀 Features

- ✅ Upload file metadata (filename, timestamp, S3 URL)
- ✅ Query metadata by filename
- ✅ Store records in AWS DynamoDB (or local mock)
- ✅ Support for S3 file links
- 🧩 (Planned) Lambda-based querying & notifications
- 🛠️ (Planned) Infrastructure as Code with Terraform

---

## 🧱 Tech Stack

### Backend:
- Java 17
- Spring Boot 3.3.x
- AWS SDK for Java v2 (DynamoDB, S3)
- Lombok

### Frontend (Planned):
- React + TypeScript
- Vite
- axios
- shadcn/ui or Tailwind CSS

---

## 📦 Project Structure (Backend)

```bash
src/
├── main/
│   ├── java/com/tonyyang/fileuploadlookup/
│   │   ├── controller/          # REST API controllers
│   │   ├── service/             # Business logic layer
│   │   └── model/               # Data models
│   └── resources/
│       └── application.properties
```

---

## 🛠️ Getting Started (Backend)

### Prerequisites

- JDK 17+
- AWS credentials in `~/.aws/credentials` or EC2 IAM role
- Maven

### Run locally

```bash
./mvnw spring-boot:run
```

Spring Boot app will be available at:  
`http://localhost:8080`

---

## 📬 API Reference

### Upload metadata

```http
POST /upload-metadata
Content-Type: application/json
```

**Example request:**

```json
{
  "filename": "example.pdf",
  "uploadTime": "2025-07-08T12:00:00Z",
  "s3Url": "https://your-bucket.s3.amazonaws.com/example.pdf"
}
```

---

### Query metadata

```http
GET /files?filename=example.pdf
```

**Example response:**

```json
{
  "filename": "example.pdf",
  "uploadTime": "2025-07-08T12:00:00Z",
  "s3Url": "https://your-bucket.s3.amazonaws.com/example.pdf"
}
```

---

## 🌐 Deployment (Optional)

- ✅ Backend: EC2 instance behind ALB (Application Load Balancer)
- ✅ Frontend: Static assets on S3 + CloudFront
- ✅ Lambda functions for serverless queries and notifications
- ✅ Terraform templates for infrastructure provisioning

---

## 📌 Roadmap

- [x] Backend REST API: upload & store metadata
- [x] DynamoDB integration
- [ ] Frontend with file upload & query UI
- [ ] S3 file upload support
- [ ] Lambda + SNS notification integration
- [ ] Terraform deployment automation

---

## 👨‍💻 Author

Tony Yang · [@bb3696](https://github.com/bb3696)

---

## 📄 License

This project is licensed under the MIT License.
