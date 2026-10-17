# 📱 Task Manager — Flutter Mobile Application

> A sleek, cross-platform mobile application built with **Flutter 3**, **Riverpod**, and **GoRouter**, designed as the mobile companion to the **Task Manager** web platform. It connects seamlessly to the Laravel REST API backend to provide real-time task tracking, smart categorization, and personalized settings.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture & Tech Stack](#-architecture--tech-stack)
- [Application Navigation & Screen Flows](#-application-navigation--screen-flows)
  - [1. Onboarding & Authentication Flow](#1-onboarding--authentication-flow)
  - [2. Main Dashboard & Task Management](#2-main-dashboard--task-management)
  - [3. Settings Drawer & Sub-Screens](#3-settings-drawer--sub-screens)
- [Network & API Configuration](#-network--api-configuration)
  - [Connecting to Local Laravel Backend](#connecting-to-local-laravel-backend)
  - [Environment Flags (--dart-define)](#environment-flags---dart-define)
- [Getting Started & Local Setup](#-getting-started--local-setup)
  - [Prerequisites](#prerequisites)
  - [Installation & Running](#installation--running)
- [Running Tests](#-running-tests)
- [Directory Structure](#-directory-structure)

---

## 🌟 Overview

The **Task Manager Mobile Application** empowers users to manage their daily agendas on the go. Built with Flutter, it delivers a smooth 60fps native experience on both **Android** and **iOS** while maintaining visual parity with the companion web app (matching typography, cohesive color palette, and identical task categorization logic).

The app authenticates against the Laravel backend via **Laravel Sanctum Bearer tokens**, securely stores session credentials in encrypted device storage, and tracks user client telemetry (`flutter-mobile`).

---

## ✨ Key Features

### 1. 🔐 Secure Authentication & Session Lifecycle
- **Encrypted Token Persistence**: Uses `flutter_secure_storage` (Android Keystore / iOS Keychain) to store the Sanctum Bearer token.
- **Smart Splash Route**: Verifies existing tokens on launch via `/api/v1/user`. Automatically redirects authenticated users to the dashboard and unauthenticated users to the welcome screen.
- **Streamlined Login**: Real-time form validation, password visibility toggle, responsive error alerts, and loading spinners.
- **Password Recovery**: Integrated in-app **Forgot Password** and **Reset Password** flows connected to backend API routes.
- **Companion Registration Link**: Web app redirection via `url_launcher` for account creation and email verification.

### 2. ⚡ Intelligent Real-Time Task Management
- **Synchronized Task Bucketing**: Mirrors the web app's categorization:
  - **Today**: Active tasks due before the end of today.
  - **Upcoming**: Scheduled future tasks.
  - **Past Due**: Overdue tasks styled with distinct error accents for urgency.
  - **Completed**: Accomplished tasks with completion dates.
- **Interactive Task Operations**:
  - **Create Task**: Bottom sheet modal (`TaskFormSheet`) with title, description, and interactive date & time pickers.
  - **Inline Toggle**: Tap the check circle icon on any task card to immediately switch between pending and completed.
  - **Edit Task**: Open bottom sheet pre-populated with task data.
  - **Delete Task**: Quick removal with confirmation snackbar notifications.
- **Pull-to-Refresh**: Refresh indicator updates both the task list and user profile simultaneously.
- **Live Clock Provider**: Automatically recomputes overdue and today categories as time passes without requiring app reloads.

### 3. 📊 Visual Dashboard Overview
- **Metric Summary Cards**: 2x2 grid displaying immediate statistics:
  - 📅 **Today** count & description.
  - ⏰ **Upcoming** count.
  - ⚠️ **Past Due** count (highlights in red when overdue tasks exist).
  - ✅ **Completed** count.
- **Empty States**: Friendly empty state illustration with a quick "+ Add Task" shortcut when no tasks exist.

### 4. 🎨 Customization & Theming
- Built with **Material 3** design system tailored to match the web app:
  - Typography: **Google Fonts (Instrument Sans)**.
  - Icons: **Lucide Icons Flutter** (`lucide_icons_flutter`).
- **Theme Modes**: Supports **Light Mode**, **Dark Mode**, and **System Preference**, persisted across app restarts via `shared_preferences`.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technologies & Packages |
| :--- | :--- |
| **Framework** | Flutter 3.x / Dart ^3.12.2 |
| **State Management** | `flutter_riverpod` (^3.4.3) |
| **Routing & Navigation** | `go_router` (^17.5.0) |
| **Networking & HTTP** | `dio` (^5.11.1) with token interceptor |
| **Secure Token Storage** | `flutter_secure_storage` (^11.2.0) |
| **Local Preferences** | `shared_preferences` (^2.5.6) |
| **Date & Time Formatting** | `intl` (^0.20.3) |
| **Typography & Icons** | `google_fonts` (`Instrument Sans`), `lucide_icons_flutter` |
| **Deep Linking & URLs** | `url_launcher` (^6.3.3) |

---

## 🗺️ Application Navigation & Screen Flows

### 1. Onboarding & Authentication Flow

```
                  [ /splash ]
                 /           \
     (Unauthenticated)    (Authenticated)
            ↓                    ↓
       [ /welcome ]        [ /dashboard ]
            ↓
        [ /login ]
        /        \
[ /forgot-password ]  [ Companion Web Registration ]
        ↓
[ /reset-password ]
```

1. **Splash Screen (`/splash`)**:
   - Initial entry route. Inspects secure storage for an existing token and calls `/api/v1/user`.
   - If valid, redirects directly to `/dashboard`. Otherwise, redirects to `/welcome`.
2. **Welcome Screen (`/welcome`)**:
   - Shows the app logo, mission statement, and primary **"Log in"** button.
   - Includes a hyperlink opening the web app in the device browser for users needing to create a new account.
3. **Login Screen (`/login`)**:
   - Accepts registered email and password.
   - Shows validation messages and API errors if credentials fail.
   - Direct link to password recovery.
4. **Forgot Password (`/forgot-password`)**:
   - Submits email to receive a password reset token from the backend.
5. **Reset Password (`/reset-password`)**:
   - Accepts reset token, email, and new password.

---

### 2. Main Dashboard & Task Management

```
[ App Bar: Logo + Drawer Hamburger ]
  ├── 👤 Welcome Header & Today's Date
  ├── ➕ "Add Task" Button
  ├── 📊 2x2 Metric Summary Grid (Today, Upcoming, Past Due, Completed)
  └── 📋 Categorized Task Lists:
        ├── ☀️ Today Section
        │     └── [ Task Card: Check Circle | Details | Edit | Delete ]
        ├── ⏳ Upcoming Section
        ├── 🚨 Past Due Section
        └── ✔️ Completed Section
```

#### Navigating the Dashboard:
- **Header**: Displays user's name (`Welcome back, {User}!`) and current date.
- **Adding a Task**: Tap the **"Add Task"** button at the top right to open the bottom sheet modal. Choose a title, optional description, and select the due date & time.
- **Interacting with Task Cards**:
  - **Toggle Completion**: Tap the circle icon on the left of any task card. A green check icon indicates completion.
  - **Edit Details**: Tap the pencil button to edit title, description, or reschedule.
  - **Delete Task**: Tap the trash icon to delete the task.
- **Refresh**: Pull down from the top to refresh tasks and user data.

---

### 3. Settings Drawer & Sub-Screens

Tap the hamburger menu icon (top left of the Dashboard app bar) to slide out the **Settings Drawer**:

```
[ Settings Drawer ]
  ├── 🏷️ App Logo & Header
  ├── 📊 Dashboard (/dashboard)
  ├── ⚙️ SETTINGS:
  │     ├── 👤 Profile (/settings/profile)
  │     ├── ☀️ Appearance (/settings/appearance)
  │     └── 🛡️ Security (/settings/security)
  └── 🚪 Footer: User Info (Name, Email) & Log Out
```

#### Sub-Screens:
- **Profile (`/settings/profile`)**:
  - Displays user name, email, email verification status, and registered account metadata.
  - Includes a link to manage full profile attributes on the web app.
- **Appearance (`/settings/appearance`)**:
  - Switch between **Light Mode**, **Dark Mode**, and **System Default**.
  - Instant live preview and persistent preference storage.
- **Security (`/settings/security`)**:
  - Displays password update instructions and link to web portal for Two-Factor Authentication (2FA) setup.
- **Log Out**:
  - Revokes current Sanctum token via `/api/v1/logout`, clears local secure storage, and returns user to the Welcome screen.

---

## 🌐 Network & API Configuration

The mobile app communicates with the Laravel backend via `AppConfig` located at [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart).

### Connecting to Local Laravel Backend

Because local development hostnames differ depending on whether you are running on an emulator, simulator, or real device, use the appropriate base URL:

| Target Device | `API_BASE_URL` | `WEB_URL` |
| :--- | :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:8000/api/v1` | `http://10.0.2.2:8000` |
| **iOS Simulator** | `http://127.0.0.1:8000/api/v1` | `http://127.0.0.1:8000` |
| **Chrome / Web** | `http://localhost:8000/api/v1` | `http://localhost:8000` |
| **Physical Phone (Wi-Fi)** | `http://<LAN_IP>:8000/api/v1` *(e.g. `192.168.1.100`)* | `http://<LAN_IP>:8000` |

> 💡 **Tip for Physical Devices**: Make sure your mobile device and computer running Laravel are on the same Wi-Fi network, and that Laravel is serving on `0.0.0.0`:
> ```bash
> php artisan serve --host=0.0.0.0 --port=8000
> ```

---

### Environment Flags (`--dart-define`)

You can override the API and Web URLs at compile/run time without altering source code:

```bash
# Run on Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 --dart-define=WEB_URL=http://10.0.2.2:8000

# Run on Physical Device
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1 --dart-define=WEB_URL=http://192.168.1.100:8000
```

---

## 🚀 Getting Started & Local Setup

### Prerequisites

Ensure you have the following installed:
- **Flutter SDK** (>= 3.24.x, Dart >= 3.12)
- **Android Studio** (with Android SDK & Emulator) or **Xcode** (for iOS simulator)
- Running instance of the **Task Manager Web Backend** (`task_manager`) on port 8000

---

### Installation & Running

1. Navigate to the mobile project directory:
   ```bash
   cd task_manager_mobile
   ```

2. Fetch Flutter package dependencies:
   ```bash
   flutter pub get
   ```

3. Verify connected devices / emulators:
   ```bash
   flutter devices
   ```

4. Launch the app:
   ```bash
   # Run on default connected device
   flutter run

   # Or specify a target device (e.g., Chrome or Android emulator)
   flutter run -d chrome
   flutter run -d emulator-5554
   ```

---

## 🧪 Running Tests

Execute the unit and widget test suite:

```bash
flutter test
```

Run Dart static analysis to ensure code quality:
```bash
flutter analyze
```

---

## 📁 Directory Structure

```
task_manager_mobile/
├── lib/
│   ├── app.dart                                # MaterialApp, theme & router binding
│   ├── main.dart                               # Entry point & ProviderScope initialization
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart                 # API_BASE_URL & WEB_URL configuration
│   │   ├── network/
│   │   │   ├── api_client.dart                 # Dio client with Bearer auth interceptor
│   │   │   └── api_exception.dart              # Normalized error model & validator errors
│   │   ├── router/
│   │   │   └── app_router.dart                 # GoRouter with reactive auth redirection
│   │   ├── storage/
│   │   │   └── secure_storage.dart             # Sanctum token secure storage provider
│   │   ├── theme/
│   │   │   ├── app_colors.dart                 # Light & dark theme palettes
│   │   │   └── app_theme.dart                  # Material 3 theme data & typography
│   │   └── widgets/                            # Shared buttons, text fields, logo, splash
│   └── features/
│       ├── auth/
│       │   ├── data/auth_repository.dart       # Login, forgot & reset password API calls
│       │   ├── models/auth_models.dart         # User & auth state models
│       │   ├── state/auth_controller.dart      # Riverpod AuthController & notifier
│       │   └── ui/                             # Welcome, Login, Password Reset screens
│       ├── tasks/
│       │   ├── data/
│       │   │   ├── task_model.dart             # Task data model & JSON serialization
│       │   │   └── task_repository.dart        # CRUD API operations
│       │   ├── state/
│       │   │   ├── categorized_tasks_provider.dart # Dynamic categorization (Today, Upcoming...)
│       │   │   ├── clock_provider.dart         # Periodic clock ticker
│       │   │   └── tasks_controller.dart       # Riverpod task list controller
│       │   └── ui/
│       │       ├── dashboard_screen.dart       # Main task dashboard
│       │       └── widgets/                    # Task card, form sheet, summary metric cards
│       └── settings/
│           ├── state/theme_controller.dart     # Theme mode persistence provider
│           └── ui/
│               ├── appearance_screen.dart      # Light / Dark / System mode selector
│               ├── profile_screen.dart         # User profile metadata view
│               ├── security_screen.dart        # Security & 2FA guidance
│               └── settings_drawer.dart        # Main slide-out navigation drawer
└── test/
    ├── core/                                   # Network, storage, and router unit tests
    └── features/                               # Auth & Task controller tests
```

---

*Part of the Task Manager multi-platform suite. See [`task_manager/README.md`](../task_manager/README.md) for web backend documentation.*
