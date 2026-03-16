<div align="center">

<img src="assets/logo.png" alt="Task Manager Logo" width="120" height="120" />

# 📋 Task Manager

### A Professional Flutter Task Management Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-State_Mgmt-0553B1?style=for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

*A full-featured task management system with Admin & User roles, real-time notifications, email alerts, and a beautiful animated UI.*

[Features](#-features) • [Screenshots](#-screenshots) • [Architecture](#-architecture) • [Setup](#-getting-started) • [Tech Stack](#-tech-stack)

---

</div>

## ✨ Features

### 👑 Admin Features
| Feature | Description |
|---|---|
| 🗂️ **Admin Dashboard** | Real-time task stats — Total, Completed, Pending, Overdue |
| ➕ **Create Users** | Add team members with auto-generated credentials emailed instantly |
| 📌 **Assign Tasks** | Create & assign tasks with priority levels and due dates |
| 👥 **Team Management** | View, search, and remove team members |
| 🔔 **Admin Alerts** | Real-time notifications when users complete tasks |
| ⚙️ **Settings** | Edit profile name, upload profile photo, sign out |

### 👤 User Features
| Feature | Description |
|---|---|
| 🏠 **User Dashboard** | Personal task overview with live stats |
| ✅ **Task Management** | Start, complete, and track assigned tasks |
| 🔔 **Notifications** | Instant alerts when new tasks are assigned |
| ⚙️ **Settings** | Edit name, change profile photo (gallery/camera), sign out |

### 🔐 Auth Features
- Email & Password login
- Google Sign-In
- Forgot Password with deep-link reset
- Persistent sessions with auto-login
- Role-based access (Admin / User)

---

## 📱 Screenshots

<div align="center">

### 🔐 Authentication

| Splash Screen | Login Screen | Forgot Password |
|:---:|:---:|:---:|
| <img src="screenshots/splash.png" width="200"/> | <img src="screenshots/login.png" width="200"/> | <img src="screenshots/forgot.png" width="200"/> |

### 👑 Admin Panel

| Dashboard | Assign Task | Team Members |
|:---:|:---:|:---:|
| <img src="screenshots/admin_dashboard.png" width="200"/> | <img src="screenshots/assign_task.png" width="200"/> | <img src="screenshots/team.png" width="200"/> |

| Admin Alerts | Settings |
|:---:|:---:|
| <img src="screenshots/admin_alerts.png" width="200"/> | <img src="screenshots/settings.png" width="200"/> |

### 👤 User Panel

| User Dashboard | My Tasks | Notifications |
|:---:|:---:|:---:|
| <img src="screenshots/user_dashboard.png" width="200"/> | <img src="screenshots/user_tasks.png" width="200"/> | <img src="screenshots/user_notif.png" width="200"/> |

</div>

> 📸 **To add screenshots:** Create a `screenshots/` folder in your repo root and add your phone screenshots with the filenames shown above.

---

## 🏗️ Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/
│   ├── services/          # Email, notifications, profile image, session
│   ├── theme/             # App theme & colors
│   └── utils/             # Constants
│
├── data/
│   └── repositories/      # Supabase + local implementations
│
├── domain/
│   ├── entities/          # User, Task models
│   └── repositories/      # Abstract interfaces
│
└── presentation/
    ├── providers/          # Riverpod state management
    └── screens/
        ├── admin/          # Dashboard, Assign Task, Team, Alerts
        ├── auth/           # Login, Signup, Forgot Password, Splash
        ├── user/           # Dashboard, Tasks, Notifications
        ├── settings_screen.dart
        └── main_screen.dart
```

### State Management
- **Riverpod** — all state managed via `Provider`, `StateNotifier`, `StreamProvider`, `FutureProvider`
- Real-time data via **Supabase Realtime** streams
- Persistent auth sessions via `SharedPreferences` + `FlutterSecureStorage`

---

## 🗄️ Database Schema (Supabase)

```sql
-- Users table
users (
  id          UUID PRIMARY KEY,
  name        TEXT,
  email       TEXT UNIQUE,
  role        TEXT,           -- 'admin' | 'user'
  created_by_admin_id UUID
)

-- Tasks table
tasks (
  id              UUID PRIMARY KEY,
  title           TEXT,
  description     TEXT,
  priority        TEXT,       -- 'Low' | 'Medium' | 'High'
  status          TEXT,       -- 'Pending' | 'In Progress' | 'Completed'
  dueDate         TIMESTAMP,
  assignedToId    UUID,
  assignedToName  TEXT,
  admin_id        UUID,
  createdAt       TIMESTAMP,
  completedAt     TIMESTAMP
)

-- Notifications table
notifications (
  id          UUID PRIMARY KEY,
  user_id     UUID,
  title       TEXT,
  message     TEXT,
  type        TEXT,
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMP DEFAULT now()
)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.5.0`
- Dart SDK `^3.5.0`
- Android Studio / VS Code
- Supabase account
- EmailJS account

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/FA23-BSSE-024-5A-Ali-Hassan/task_manager.git
cd task_manager
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Supabase**

Update `lib/main.dart` with your credentials:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

**4. Configure EmailJS**

Update `lib/core/services/email_service.dart`:
```dart
static const String serviceId = 'YOUR_SERVICE_ID';
static const String publicKey = 'YOUR_PUBLIC_KEY';
```

**5. Set up app icon**
```bash
dart run flutter_launcher_icons
```

**6. Run the app**
```bash
flutter run
```

---

## 📧 Email Notifications

Emails are sent via **EmailJS** for:

| Event | Recipient | Template |
|---|---|---|
| New user created | New user | Welcome + credentials |
| Task assigned | Assigned user | Task details |
| Task completed | Admin | Completion alert |

---

## 🔔 Notifications System

- **In-app** — Real-time via Supabase Realtime stream
- **Push** — Local push notifications on task events
- **Email** — EmailJS for critical events
- Notifications persist in Supabase `notifications` table
- Swipe to dismiss, tap to mark as read

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Backend** | Supabase (PostgreSQL + Realtime + Auth) |
| **State Management** | Flutter Riverpod 2.x |
| **Authentication** | Supabase Auth + Google Sign-In |
| **Email** | EmailJS |
| **Local Storage** | SharedPreferences + FlutterSecureStorage |
| **Image Picking** | image_picker |
| **HTTP Client** | http + dio |
| **Fonts** | Google Fonts (Poppins) |

---

## 📦 Key Dependencies

```yaml
flutter_riverpod: ^2.5.1      # State management
supabase_flutter: ^2.6.0      # Backend & realtime
google_sign_in: ^6.2.1        # Google auth
emailjs: ^4.0.0               # Email notifications
flutter_secure_storage: ^9.0.0 # Secure token storage
shared_preferences: ^2.2.3    # Session persistence
image_picker: ^1.0.9          # Profile photo upload
google_fonts: ^6.1.0          # Typography
intl: ^0.19.0                 # Date formatting
uuid: ^4.5.2                  # Unique IDs
```

---

## 🔑 Environment Setup

### Supabase Dashboard Setup
1. Create tables: `users`, `tasks`, `notifications`
2. Enable **Row Level Security** (RLS) policies
3. Authentication → URL Configuration:
   - **Redirect URLs:** `com.hassan.pro.task.manager://reset-password`
4. Enable **Google OAuth** provider

### EmailJS Setup
1. Create two email templates:
   - `template_x79uv3n` — Task Assigned / Completed
   - `template_76umo0q` — New User Welcome
2. Template variables: `{{to_email}}`, `{{name}}`, `{{user_name}}`, `{{task_title}}`, `{{password}}`, `{{role}}`

---

## 👨‍💻 Developer

<div align="center">

**Ali Hassan**
*FA23-BSSE-024*

[![GitHub](https://img.shields.io/badge/GitHub-FA23--BSSE--024--5A--Ali--Hassan-181717?style=for-the-badge&logo=github)](https://github.com/FA23-BSSE-024-5A-Ali-Hassan)

</div>

---

## 📄 License

```
MIT License — feel free to use this project for learning and development.
```

---

<div align="center">

Made with ❤️ using Flutter & Supabase

⭐ **Star this repo if you found it helpful!**

</div>
