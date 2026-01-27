# Expense Tracker

A desktop expense tracking app for small businesses. Built with Flutter and Supabase.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## What's This?

We built this app to help small businesses track expenses without the headache. It works offline, syncs when you're connected, and runs on Windows, macOS, and Linux.

**Why we made it:**
- Most expense trackers are either too simple or way too complex
- Small businesses need something in between
- We wanted offline-first with optional cloud sync

## Features

**What's working now:**

- ✅ Add, edit, delete expenses with categories
- ✅ Role-based access (Owner → Manager → Employee)
- ✅ Organization management with approval workflow
- ✅ Dashboard with spending charts
- ✅ Budget tracking per category
- ✅ Export to CSV and PDF
- ✅ Receipt attachments (Supabase Storage)
- ✅ Real-time sync across devices
- ✅ Offline mode (keeps working without internet)
- ✅ Dark mode support

**On the roadmap:**

- 🔜 Multi-currency support
- 🔜 Recurring expenses
- 🔜 OCR receipt scanning
- 🔜 Advanced analytics

## Tech Stack

| What | Why |
|------|-----|
| Flutter | Cross-platform desktop UI |
| Supabase | Auth, database, storage, real-time |
| Drift + SQLite | Local offline storage |
| Riverpod | State management |
| fl_chart | Charts and graphs |
| go_router | Navigation |

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Git

**Platform-specific:**

| Windows | macOS | Linux |
|---------|-------|-------|
| Visual Studio 2022 with C++ tools | Xcode 14+ | GTK 3.0, clang, CMake |

### Setup

```bash
# Clone it
git clone https://github.com/houubeer/Expense-Tracking
cd expense-tracker

# Install dependencies
flutter pub get

# Generate database code
dart run build_runner build

# Run it
flutter run -d windows  # or macos, linux
```

### Environment Setup

Copy `.env.example` to `.env` and add your Supabase credentials:

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

## Project Structure

```
lib/
├── app.dart                    # App entry widget
├── main.dart                   # Entry point
├── main_dev.dart               # Dev environment
├── main_staging.dart           # Staging environment
├── main_production.dart        # Production environment
│
├── config/
│   ├── environment.dart        # Environment configuration
│   └── supabase_config.dart    # Supabase setup
│
├── constants/
│   ├── app_config.dart
│   ├── app_routes.dart
│   ├── category_options.dart
│   ├── colors.dart
│   ├── durations.dart
│   ├── spacing.dart
│   ├── strings.dart
│   └── text_styles.dart
│
├── core/
│   ├── exceptions.dart
│   ├── errors/
│   └── validators/
│
├── database/
│   ├── app_database.dart       # Drift database
│   ├── app_database.g.dart     # Generated code
│   ├── connection/
│   ├── daos/                   # Data Access Objects
│   ├── tables/
│   └── i_database.dart
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── budget/
│   │
│   ├── dashboard/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── view_models/
│   │   └── widgets/
│   │
│   ├── expenses/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── view_models/
│   │   └── widgets/
│   │
│   ├── home/
│   │
│   ├── manager_dashboard/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── view_models/
│   │   └── widgets/
│   │
│   ├── settings/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── view_models/
│   │   └── widgets/
│   │
│   └── shared/
│
├── l10n/                       # Localization
│
├── providers/
│   ├── app_providers.dart
│   └── budget_status_config_provider.dart
│
├── routes/
│   └── router.dart
│
├── screens/
│   └── expenses/
│
├── services/
│   ├── backup_service.dart
│   ├── connectivity_service.dart
│   ├── error_reporting_service.dart
│   ├── i_backup_service.dart
│   ├── logger_service.dart
│   ├── supabase_service.dart
│   └── sync_service.dart
│
├── theme/
│   └── app_theme.dart
│
├── utils/
│   ├── budget_status_calculator.dart
│   ├── formatters/
│   ├── icon_utils.dart
│   ├── sorting/
│   └── status/
│
└── widgets/
    ├── animations/
    ├── buttons.dart
    ├── connection_status_banner.dart
    ├── empty_states.dart
    └── skeleton_loader.dart

test/
├── unit/                       # Unit tests
└── widget/                     # Widget tests

integration_test/               # E2E tests
```

## Architecture

We use a layered architecture:

```
┌──────────────────────────────────────┐
│  UI (Screens, Widgets)               │
├──────────────────────────────────────┤
│  ViewModels (State, Validation)      │
├──────────────────────────────────────┤
│  Services (Business Logic)           │
├──────────────────────────────────────┤
│  Repositories (Data Abstraction)     │
├──────────────────────────────────────┤
│  DAOs (Database Operations)          │
├──────────────────────────────────────┤
│  Database (Drift/SQLite + Supabase)  │
└──────────────────────────────────────┘
```

Data flows down through user actions, back up through streams and callbacks.

## User Roles

| Role | What they can do |
|------|------------------|
| **Owner** | Approve/reject organizations, manage all data |
| **Manager** | Manage their org, add employees, view reports |
| **Employee** | Submit expenses, view own data |

## Running Tests

```bash
# Unit tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

## Building for Production

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Contributing

1. Fork it
2. Create your branch (`git checkout -b feature/cool-thing`)
3. Commit (`git commit -m 'Add cool thing'`)
4. Push (`git push origin feature/cool-thing`)
5. Open a PR

Please follow [Effective Dart](https://dart.dev/guides/language/effective-dart) and run `flutter analyze` before submitting.

## Team

| Name | GitHub |
|------|--------|
| Beradai Houssameddine Diaelhak | [@houubeer](https://github.com/houubeer) |
| Cilia Mouhoun | [@cilia-mouhoun](https://github.com/cilia-mouhoun) |
| Mohamed Islam Sahli | [@Mohamedislam19](https://github.com/Mohamedislam19) |
| Aya Brahimi | [@Aya-Brahimi](https://github.com/Aya-Brahimi) |
| Enzo Chaabnia | [@ENZOdz23](https://github.com/ENZOdz23) |

## Troubleshooting

**Drift code generation fails?**
```bash
flutter clean
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Windows build fails?**
- Install Visual Studio 2022 with "Desktop development with C++" workload
- Run `flutter doctor` to check

**Database issues?**
- Delete the database file and restart (it'll recreate on launch)
- Windows: `%APPDATA%/expense_tracker/database.sqlite`

## License

MIT - see [LICENSE](LICENSE)

---

Built by G12-Team 1
