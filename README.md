# 🐾 PetNest

> A dual-role Android app for pet owners and veterinarians — built with Kotlin, Jetpack Compose, Firebase Auth, and a Dockerized PHP/MariaDB REST API backend.

---

## 📱 About

PetNest is an Android application that connects **pet owners** and **veterinarians** in one platform. Pet owners can manage their animals and schedule appointments, while veterinarians can oversee their clients and track animal health records.

---

## ✨ Features

### 👤 Pet Owner
- Register and manage your pets (name, species, breed, age)
- Schedule and view appointments with your vet
- View health history and checkup notes

### 🩺 Veterinarian
- View and manage your client list
- Confirm or cancel appointment requests
- Add health notes after checkups

### 🔐 General
- Firebase Authentication (email/password)
- Role-based access (owner vs. veterinarian)
- Persistent login with secure token handling

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Kotlin |
| UI | Jetpack Compose |
| Architecture | MVVM |
| Authentication | Firebase Auth |
| Backend | PHP REST API |
| Database | MariaDB |
| Containerization | Docker (PHP/Apache + MariaDB) |
| Version Control | GitHub |

---

## 🏗️ Architecture

```
PetNest/
├── app/
│   ├── ui/                  # Composable screens
│   ├── viewmodel/           # ViewModels (MVVM)
│   ├── repository/          # Data layer
│   ├── model/               # Data classes
│   └── network/             # Retrofit API calls
└── backend/
    ├── api/                 # PHP REST endpoints
    ├── config/              # DB connection
    └── docker-compose.yml   # Docker setup
```

---

## 🚀 Getting Started

### Prerequisites
- Android Studio Hedgehog or newer
- Android SDK 26+
- Docker Desktop
- A Firebase project with Authentication enabled

### 1. Clone the repo
```bash
git clone https://github.com/brianvannimmen/petnest.git
cd petnest
```

### 2. Start the backend
```bash
cd backend
docker-compose up -d
```
The API will be available at `http://localhost:8080`

### 3. Configure Firebase
- Download your `google-services.json` from the Firebase Console
- Place it in `app/`

### 4. Update API base URL
In `app/network/ApiClient.kt`, set:
```kotlin
const val BASE_URL = "http://10.0.2.2:8080/api/"
```
> `10.0.2.2` is the Android emulator's alias for `localhost`

### 5. Run the app
Open the project in Android Studio and hit ▶️ Run.

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/register` | Register a new user |
| `POST` | `/auth/login` | Login and receive token |
| `GET` | `/pets` | Get all pets for the logged-in user |
| `POST` | `/pets` | Add a new pet |
| `GET` | `/appointments` | Get appointments |
| `POST` | `/appointments` | Create an appointment |
| `PUT` | `/appointments/{id}` | Update appointment status |

---

## 👨‍💻 Author

**Brian Van Nimmen**
- 🌐 [brian.dev](https://brian.dev)
- 💼 [LinkedIn](https://linkedin.com/in/brianvannimmen)
- 🐙 [GitHub](https://github.com/brianvannimmen)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
