<div align="center">

<img src="assets/logo.png" alt="TaskBoost Logo" width="120" height="120" />

# TaskBoost — Task Manager

### A Professional Flutter Task Management Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-State_Mgmt-0553B1?style=for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-Ali--Hassan--edu-181717?style=for-the-badge&logo=github)](https://github.com/Ali-Hassan-edu)

> *A full-featured task management system with Admin & User roles, real-time notifications, email alerts, password reset, and a beautiful animated UI — built with Flutter & Supabase.*

[Features](#-features) • [Screenshots](#-screenshots) • [Architecture](#-architecture) • [Setup](#-getting-started) • [Tech Stack](#-tech-stack)

---

</div>

## ✨ Features

### 👑 Admin Features
| Feature | Description |
|---|---|
| 🗂️ **Admin Dashboard** | Real-time stats — Total, Completed, Pending, Overdue with progress bar |
| ➕ **Create Users** | Add team members; credentials auto-emailed instantly |
| 📌 **Assign Tasks** | Create & assign tasks with priority (Low/Medium/High) and due dates |
| 👥 **Team Management** | View, search and manage all team members |
| 🔔 **Admin Alerts** | Real-time notifications when users complete tasks |
| ⚙️ **Settings** | Profile photo upload (gallery/camera), edit name, sign out |

### 👤 User Features
| Feature | Description |
|---|---|
| 🏠 **User Dashboard** | Personal stats: Total, Pending, Active, Done |
| ✅ **Task Management** | Start and complete tasks with tab-based view (Pending / In Progress / Done) |
| 🔔 **Notifications** | Real-time alerts when new tasks are assigned |
| ⚙️ **Settings** | Profile photo, display name, app version |

### 🔐 Auth Features
- Email & Password login
- Google Sign-In (OAuth)
- Forgot Password with deep-link reset (PKCE flow)
- Persistent sessions with auto-login
- Role-based routing (Admin / User)

---

## 📱 Screenshots

### 🔐 Authentication

<div align="center">

| Splash Screen | Login Screen | Forgot Password |
|:---:|:---:|:---:|
| <img src="screenshots/splash.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/login.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/forgot.jpeg" width="200" style="border-radius:12px"/> |

</div>

### 👑 Admin Panel

<div align="center">

| Dashboard | Assign Task | Team Members |
|:---:|:---:|:---:|
| <img src="screenshots/admin_dashboard.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/assign_task.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/team.jpeg" width="200" style="border-radius:12px"/> |

| Admin Alerts | Settings |
|:---:|:---:|
| <img src="screenshots/admin_alerts.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/settings.jpeg" width="200" style="border-radius:12px"/> |

</div>

### 👤 User Panel

<div align="center">

| User Dashboard | My Tasks | Notifications |
|:---:|:---:|:---:|
| <img src="screenshots/user_dashboard.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/user_tasks.jpeg" width="200" style="border-radius:12px"/> | <img src="screenshots/user_notif.jpeg" width="200" style="border-radius:12px"/> |

</div>

---

## 🏗️ Architecture

Clean Architecture with clear separation of concerns:

```
lib/
├── core/
│   ├── services/        # Email, push notifications, profile image, session
│   ├── theme/           # App theme & colors
│   └── utils/           # Constants
│
├── data/
│   └── repositories/    # Supabase + local implementations
│
├── domain/
│   ├── entities/        # User, Task models
│   └── repositories/    # Abstract interfaces
│
└── presentation/
    ├── providers/        # Riverpod state management
    └── screens/
        ├── admin/        # Dashboard, Assign Task, Team, Alerts
        ├── auth/         # Login, Signup, Forgot/Reset Password, Splash
        ├── user/         # Dashboard, Tasks, Notifications
        ├── settings_screen.dart
        └── main_screen.dart
```

### State Management
- **Riverpod** — `Provider`, `StateNotifier`, `StreamProvider`, `FutureProvider`
- **Real-time** data via Supabase Realtime streams
- **Persistent** auth via `SharedPreferences` + `FlutterSecureStorage`

---

## 🗄️ Database Schema

```sql
-- Users
users (
  id                  UUID PRIMARY KEY,
  name                TEXT,
  email               TEXT UNIQUE,
  role                TEXT,        -- 'admin' | 'user'
  created_by_admin_id UUID
)

-- Tasks
tasks (
  id              UUID PRIMARY KEY,
  title           TEXT,
  description     TEXT,
  priority        TEXT,            -- 'Low' | 'Medium' | 'High'
  status          TEXT,            -- 'Pending' | 'In Progress' | 'Completed'
  dueDate         TIMESTAMP,
  assignedToId    UUID,
  assignedToName  TEXT,
  admin_id        UUID,
  createdAt       TIMESTAMP,
  completedAt     TIMESTAMP
)

-- Notifications
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
git clone https://github.com/Ali-Hassan-edu/task_manager.git
cd task_manager
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Supabase**

Update `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

**4. Configure EmailJS**

Update `lib/core/services/email_service.dart`:
```dart
static const String serviceId  = 'YOUR_SERVICE_ID';
static const String publicKey  = 'YOUR_PUBLIC_KEY';
```

**5. Generate app icon**
```bash
dart run flutter_launcher_icons
```

**6. Run**
```bash
flutter run
```

---

## 📧 Email Notifications

Emails sent via **EmailJS** for:

| Event | Recipient | Template |
|---|---|---|
| New user created | New user | Welcome + login credentials |
| Task assigned | Assigned user | Task details |
| Task completed | Admin | Completion alert |

---

## 🔔 Notification System

| Type | How |
|---|---|
| **In-app** | Supabase Realtime stream — appears instantly |
| **Push** | Local push notification on task events |
| **Email** | EmailJS for critical events |

Notifications persist in Supabase `notifications` table. Swipe to dismiss, tap to mark as read.

---

## 🔑 Supabase Setup

1. Create tables: `users`, `tasks`, `notifications`
2. Enable **Row Level Security** (RLS)
3. **Authentication → URL Configuration:**
   - Redirect URLs: `com.hassan.pro.task.manager://reset-password`
4. Enable **Google OAuth** provider
5. Deploy Edge Function `create-user` for admin-side user creation

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Language** | Dart 3.x |
| **Backend** | Supabase (PostgreSQL + Realtime + Auth + Edge Functions) |
| **State Management** | Flutter Riverpod 2.x |
| **Authentication** | Supabase Auth + Google Sign-In |
| **Email** | EmailJS |
| **Deep Links** | app_links (PKCE password reset) |
| **Local Storage** | SharedPreferences + FlutterSecureStorage |
| **Image** | image_picker + path_provider |
| **HTTP** | http + dio |
| **Fonts** | Google Fonts |

---

## 📦 Key Dependencies

```yaml
flutter_riverpod: ^2.5.1       # State management
supabase_flutter: ^2.6.0       # Backend & realtime
google_sign_in: ^6.2.1         # Google auth
emailjs: ^4.0.0                # Email notifications
app_links: ^6.4.1              # Deep link handling
flutter_secure_storage: ^9.0.0 # Secure token storage
shared_preferences: ^2.2.3     # Session persistence
image_picker: ^1.0.9           # Profile photo upload
google_fonts: ^6.1.0           # Typography
intl: ^0.19.0                  # Date formatting
uuid: ^4.5.2                   # Unique IDs
```

---

## 👨‍💻 Developer

<div align="center">

**Ali Hassan**
*FA23-BSSE-024*

[![GitHub](https://img.shields.io/badge/GitHub-Ali--Hassan--edu-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Ali-Hassan-edu)

</div>

---

## 📄 License

```
MIT License — free to use for learning and development.
```

---

<div align="center">

Built with ❤️ using Flutter & Supabase

⭐ **Star this repo if you found it helpful!**

</div>
