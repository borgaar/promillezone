# 🏠 PromilleZone

> **Your household management companion for students and families**

PromilleZone is a fullstack application designed to streamline household management for students and families. Keep track of chores, manage shopping lists, and coordinate household activities—all in one place.

---

## ✨ Features

- 👥 **Household Management** - Create and join households with invite codes
- 📋 **Task Organization** - Coordinate chores and responsibilities
- 🛒 **Shopping Lists** - Collaborative shopping management
- 🔐 **Secure Authentication** - Firebase-powered user authentication
- ✉️ **Email Verification** - Profile verification via email
- 📱 **Cross-Platform** - Mobile and web support via Flutter

---

## 🏗️ Architecture

PromilleZone follows a modern fullstack architecture:

```
┌─────────────────────────────────────────────┐
│           Flutter Frontend                  │
│   (iOS, Android, Web, Desktop)              │
└─────────────────┬───────────────────────────┘
                  │
                  │ REST API
                  │
┌─────────────────▼───────────────────────────┐
│         Rust Backend (Axum)                 │
│   • Firebase Authentication                 │
│   • RESTful API                             │
│   • OpenAPI Documentation                   │
└─────────────────┬───────────────────────────┘
                  │
                  │ SeaORM
                  │
┌─────────────────▼───────────────────────────┐
│          PostgreSQL Database                │
└─────────────────────────────────────────────┘
```

---

## 🚀 Tech Stack

### Frontend

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: flutter_bloc
- **Routing**: go_router
- **Authentication**: Firebase Auth

### Backend

- **Language**: [Rust](https://www.rust-lang.org/)
- **Web Framework**: [Axum](https://github.com/tokio-rs/axum)
- **ORM**: [SeaORM](https://www.sea-ql.org/SeaORM/)
- **Database**: PostgreSQL
- **Authentication**: Firebase JWT verification
- **API Documentation**: OpenAPI (via utoipa)
- **Email**: Resend

---

## 📂 Project Structure

```
promillezone/
├── frontend/          # Flutter application
│   └── README.md      # Frontend setup guide
│
└── backend/           # Rust API server
    └── README.md      # Backend setup guide
```

---

## 🛠️ Getting Started

### Prerequisites

- **Frontend**:

  - Flutter SDK
  - Dart SDK
  - Firebase account & configuration

- **Backend**:
  - Rust
  - PostgreSQL
  - Cargo
  - Firebase service account

### Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/borgaar/promillezone.git
   cd promillezone
   ```

2. **Set up the backend**

   ```bash
   cd backend
   # See backend/README.md for detailed instructions
   ```

3. **Set up the frontend**
   ```bash
   cd frontend
   # See frontend/README.md for detailed instructions
   ```

> 📖 **For detailed setup instructions**, please refer to the individual README files in the `frontend/` and `backend/` directories.

---

## 🐳 Docker Support

Run the entire stack with Docker Compose:

```bash
cd backend
docker compose up
```

This will start:

- PostgreSQL database on port `5432`
- Backend API on port `3000`

---

## 📡 API Documentation

The backend provides interactive API documentation powered by Scalar:

- **Local**: http://localhost:3000/scalar
- **OpenAPI Spec**: http://localhost:3000/api-docs/openapi.json

## 🔐 Authentication

PromilleZone uses Firebase Authentication with custom JWT verification:

1. Users authenticate via Firebase on the frontend
2. JWT tokens are sent with API requests
3. Backend middleware verifies tokens
4. Protected routes require valid authentication

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is currently unlicensed. All rights reserved.

---

## 👨‍💻 Author

**Borgar**

- GitHub: [@borgaar](https://github.com/borgaar)

**Anders**

- GitHub: [@lille-morille](https://github.com/lille-morill)

---

<div align="center">

**[⬆ back to top](#-promillezone)**

Made by students, for students

</div>
