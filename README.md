# Expense Tracker for Small Business

A comprehensive desktop expense tracking application built with Flutter, designed specifically for small businesses to manage their finances efficiently. This application leverages Drift with SQLite for robust local data persistence and offline-first functionality.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Drift](https://img.shields.io/badge/Drift-Latest-orange)](https://drift.simonbinder.eu/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Usage](#usage)
- [Building for Production](#building-for-production)
- [Contributing](#contributing)
- [Team](#team)
- [License](#license)
- [Support](#support)

## Overview

Expense Tracker is a desktop application tailored for small businesses seeking a reliable, offline-capable solution for managing expenses, invoices, and financial records. Built with Flutter's cross-platform capabilities, it runs seamlessly on Windows, macOS, and Linux.

### Key Highlights

- **Offline-First Architecture**: All data stored locally using Drift + SQLite
- **Cross-Platform**: Single codebase for Windows, macOS, and Linux
- **Small Business Focused**: Features designed specifically for SMB financial management
- **Fast & Responsive**: Native desktop performance with Flutter
- **Data Privacy**: Complete control over your financial data - no cloud storage required

## Features

### Core Functionality

- **📊 Expense Management**

  - Add, edit, and delete expenses with detailed categorization
  - Attach receipts and supporting documents
  - Multi-currency support
  - Recurring expense tracking

- **📈 Financial Reports**

  - Monthly/quarterly/annual expense summaries
  - Category-wise spending analysis
  - Profit & loss statements
  - Export reports to PDF/Excel

- **🏷️ Categories**

  - Customizable expense categories
  - Budget allocation per category

- **🔍 Advanced Search & Filtering**

  - Search by date range, category, amount
  - Custom filter combinations

- **📅 Dashboard**
  - Real-time financial overview
  - Visual charts and graphs
  - Spending trends and insights

## Technology Stack

| Technology   | Purpose                       |
| ------------ | ----------------------------- |
| **Flutter**  | Cross-platform UI framework   |
| **Dart**     | Programming language          |
| **Drift**    | Type-safe Dart ORM for SQLite |
| **SQLite**   | Local database engine         |
| **Riverpod** | State management              |
| **fl_chart** | Data visualization            |
| **pdf**      | Report generation             |

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher
- **Git**: For version control
- **IDE**: VS Code or Android Studio with Flutter plugins

### Platform-Specific Requirements

#### Windows

- Visual Studio 2022 with C++ desktop development tools

#### macOS

- Xcode 14 or higher
- CocoaPods

#### Linux

- GTK 3.0 development libraries
- clang
- CMake
- ninja-build

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/houubeer/Expense-Tracking
cd expense-tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Drift Database Code

```bash
dart run build_runner build
```

For continuous code generation during development:

```bash
dart run build_runner watch
```

### 4. Run the Application

```bash
# For development
flutter run -d windows  # or macos, linux

# With hot reload enabled
flutter run -d windows --hot
```

## Project Structure

```
expense-tracker/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── database/
│   │   │   ├── database.dart          # Drift database configuration
│   │   │   ├── tables/                # Table definitions
│   │   │   └── daos/                  # Data Access Objects
│   │   ├── models/
│   │   └── repositories/
│   ├── features/
│   │   ├── dashboard/
│   │   ├── expenses/
│   │   ├── income/
│   │   ├── reports/
│   │   └── settings/
│   ├── shared/
│   │   ├── widgets/
│   │   └── services/
│   └── main.dart
├── assets/
│   ├── images/
│   └── fonts/
├── test/
├── windows/
├── macos/
├── linux/
├── pubspec.yaml
└── README.md
```

## Database Schema

The application uses Drift for type-safe database operations. Key tables include:

```
Here we will include tables
```

## Usage

### Adding an Expense

1. Click the **"Add Expense"** button on the dashboard
2. Fill in the expense details (title, amount, category, date)
3. Optionally attach a receipt image
4. Click **"Save"** to record the expense

### Generating Reports

1. Navigate to the **Reports** section
2. Select the desired date range and report type
3. Click **"Generate Report"**
4. Export to PDF or Excel as needed

### Managing Categories

1. Go to **Settings** > **Categories**
2. Add, edit, or delete expense categories
3. Set budget limits for each category
4. Customize category colors and icons

## Building for Production

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### macOS

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/`

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

## Contributing

We welcome contributions from the community! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Write unit tests for new features
- Ensure code passes `flutter analyze`
- Format code with `dart format`

### Commit Message Convention

```
type(scope): subject

body

footer
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Team

This project is developed and maintained by a dedicated team of developers:

| Name                               | GitHub Profile                                       |
| ---------------------------------- | ---------------------------------------------------- |
| **Beradai Houssameddine Diaelhak** | [@houubeer](https://github.com/houubeer)             |
| **Cilia Mouhoun**                  | [@cilia-mouhoun](https://github.com/cilia-mouhoun)   |
| **Mohamed Islam Sahli**            | [@Mohamedislam19](https://github.com/Mohamedislam19) |
| **Aya Brahimi**                    | [@Aya-Brahimi](https://github.com/Aya-Brahimi)       |
| **Enzo Chaabnia**                  | [@ENZOdz23](https://github.com/ENZOdz23)             |

## Running Tests

This project includes comprehensive unit tests and integration tests to ensure code quality and reliability.

### Unit Tests

Run all unit tests with:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

View coverage report:

```bash
# Install lcov if not already installed
# On macOS: brew install lcov
# On Ubuntu: sudo apt-get install lcov
# On Windows: Use WSL or install via Chocolatey

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
# Windows: start coverage/html/index.html
# macOS: open coverage/html/index.html
# Linux: xdg-open coverage/html/index.html
```

### Integration Tests

Run integration tests:

```bash
flutter test integration_test
```

### Test Organization

Tests are organized as follows:
- `test/unit/` - Unit tests for individual components, services, repositories, and DAOs
- `integration_test/` - End-to-end integration tests for complete user flows

## Architecture Overview

This application follows a **layered architecture** pattern to ensure clean separation of concerns, testability, and maintainability.

### Layered Architecture

```
┌─────────────────────────────────────────────────┐
│              UI Layer (Screens)                  │
│  - ExpenseTable, AddExpenseScreen, etc.         │
│  - Renders UI and handles user interactions     │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│          ViewModel Layer                         │
│  - AddExpenseViewModel, etc.                    │
│  - Manages UI state and validation logic        │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│          Service Layer                           │
│  - ExpenseService, LoggerService, etc.          │
│  - Business logic, transactions, error handling │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│         Repository Layer                         │
│  - ExpenseRepository, CategoryRepository        │
│  - Abstracts data access, maps domain objects   │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│            DAO Layer                             │
│  - ExpenseDao, CategoryDao                      │
│  - Direct database operations via Drift         │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│          Database Layer                          │
│  - AppDatabase (Drift + SQLite)                 │
│  - Schema, migrations, health checks            │
└─────────────────────────────────────────────────┘
```

### Key Principles

- **Single Responsibility**: Each layer has a well-defined purpose
- **Dependency Inversion**: Upper layers depend on abstractions (interfaces), not concrete implementations
- **Interface Segregation**: Small, focused interfaces (e.g., `ICategoryReader`, `ICategoryBudgetManager`)
- **Transaction Safety**: All multi-step operations wrapped in database transactions
- **Error Handling**: Comprehensive logging and custom exceptions (`DatabaseException`, `ValidationException`)

### Data Flow

**Creating an Expense (Top to Bottom):**
1. **UI Layer**: User fills form → `AddExpenseScreen`
2. **ViewModel**: Validates input → `AddExpenseViewModel`
3. **Service**: Orchestrates transaction → `ExpenseService.createExpense()`
4. **Repository**: Maps domain objects → `ExpenseRepository.insertExpense()`
5. **DAO**: Executes SQL → `ExpenseDao.insertExpense()`
6. **Database**: Persists data → SQLite

**Displaying Expenses (Bottom to Top):**
1. **Database**: Data changes trigger stream updates
2. **DAO**: Watches table → `ExpenseDao.watchExpensesWithCategory()`
3. **Repository**: Maps to domain objects → Stream transformation
4. **Service**: Consumed by UI (or additional business logic)
5. **ViewModel**: Manages state for UI
6. **UI Layer**: Reactive rebuild → `ExpenseTable` displays data

### Cross-Cutting Concerns

- **Logging**: `LoggerService` used throughout all layers for debugging and monitoring
- **Error Reporting**: `ErrorReportingService` captures and logs exceptions with context
- **Connectivity**: `ConnectivityService` monitors network status (future cloud sync)

For detailed implementation, see:
- [LOGGING_IMPLEMENTATION.md](docs/LOGGING_IMPLEMENTATION.md) - Logging system details
- [lib/STRUCTURE.md](lib/STRUCTURE.md) - Project structure overview

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Simon Binder for the Drift library
- The open-source community for invaluable resources

---

**Made with ❤️ by G12-team 1**

_Empowering small businesses with efficient financial management_
