# Lib Directory Structure

This document explains the organization of the `lib/` directory.

## 📁 Directory Overview

```
lib/
├── main.dart                    # Application entry point
├── app.dart                     # Main app widget configuration
├── STRUCTURE.md                 # This file - project structure documentation
├── core/                        # Core application components
│   └── exceptions.dart         # Custom exception classes
├── constants/                   # App-wide constants
│   ├── colors.dart             # Color palette
│   ├── spacing.dart            # Spacing constants
│   ├── strings.dart            # String constants
│   └── text_styles.dart        # Typography styles
├── database/                    # Database layer (Drift ORM)
│   ├── app_database.dart       # Database configuration
│   ├── app_database.g.dart     # Generated database code
│   ├── i_database.dart         # Database interface
│   ├── daos/                   # Data Access Objects
│   │   ├── category_dao.dart
│   │   ├── category_dao.g.dart
│   │   ├── expense_dao.dart
│   │   └── expense_dao.g.dart
│   └── tables/                 # Table definitions
│       ├── categories_table.dart
│       └── expenses_table.dart
├── features/                    # Feature-based architecture
│   ├── budget/                 # Budget management feature
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── view_models/
│   │   └── widgets/
│   ├── expenses/               # Expense tracking feature
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── view_models/
│   │   └── widgets/
│   ├── home/                   # Dashboard feature
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── view_models/
│   │   └── widgets/
│   └── shared/                 # Shared feature components
│       └── widgets/
├── providers/                   # Riverpod providers
│   ├── app_providers.dart
│   └── budget_status_config_provider.dart
├── routes/                      # Navigation
│   └── router.dart
├── services/                    # Global services
│   ├── connectivity_service.dart
│   ├── error_reporting_service.dart
│   └── logger_service.dart
├── theme/                       # App theming
│   └── app_theme.dart
├── utils/                       # Utility functions
│   ├── formatters/
│   ├── sorting/
│   ├── status/
│   ├── budget_status_calculator.dart
│   └── icon_utils.dart
└── widgets/                     # Global reusable widgets
    ├── animations/
    ├── buttons.dart
    ├── connection_status_banner.dart
    ├── empty_states.dart
    └── skeleton_loader.dart
```

## 📂 Directory Descriptions

### `/core`

Core application components and utilities:

**Current files:**
- `exceptions.dart` - Custom exception classes (DatabaseException, ValidationException, etc.)

### `/constants`

Contains all app-wide constants including colors, spacing, strings, and text styles. This ensures consistency across the application.

**Current files:**
- `colors.dart` - Color palette definitions
- `spacing.dart` - Spacing and sizing constants
- `strings.dart` - String constants and labels
- `text_styles.dart` - Typography and text styling

### `/database`

Houses all database-related code using Drift ORM:

- **daos/**: Data Access Objects for database operations
  - `category_dao.dart` - Category CRUD operations
  - `expense_dao.dart` - Expense CRUD operations
- **tables/**: Table schema definitions
  - `categories_table.dart` - Categories table schema
  - `expenses_table.dart` - Expenses table schema
- `i_database.dart` - Database interface for dependency injection

### `/features`

**Feature-based architecture** - Each feature is self-contained with its own models, repositories, screens, services, view models, and widgets:

- **budget/**: Budget management feature
  - Complete budget tracking and category management
  - Budget status calculation and visualization
- **expenses/**: Expense tracking feature
  - Add, edit, delete expenses
  - Expense list with filtering and search
- **home/**: Dashboard feature
  - Overview of financial status
  - Quick stats and charts
- **shared/**: Shared components used across features
  - Common widgets and utilities

### `/providers`

Riverpod providers for dependency injection and state management:

**Current files:**
- `app_providers.dart` - Main application providers
- `budget_status_config_provider.dart` - Budget status configuration

### `/routes`

Navigation configuration using go_router:

**Current files:**
- `router.dart` - App routing configuration

### `/services`

Global services that sit between UI and data:

- Handles cross-cutting concerns
- Logging, error reporting, connectivity monitoring
- Keeps features decoupled from infrastructure

**Current files:**
- `connectivity_service.dart` - Database connectivity monitoring
- `error_reporting_service.dart` - Error tracking and reporting
- `logger_service.dart` - Application-wide logging

### `/theme`

Application theming and design system:

**Current files:**
- `app_theme.dart` - Theme configuration (light/dark modes)

### `/utils`

Utility functions and helpers:

- **formatters/**: Date and number formatting utilities
- **sorting/**: Category sorting strategies
- **status/**: Budget status calculation strategies
- Other helper functions

**Current files:**
- `budget_status_calculator.dart` - Budget status calculation
- `icon_utils.dart` - Icon utilities

### `/widgets`

Global reusable UI components used across multiple features:

- **animations/**: Animation widgets
- Common buttons, loaders, empty states, etc.

**Current files:**
- `buttons.dart` - Reusable button components
- `connection_status_banner.dart` - Connection status indicator
- `empty_states.dart` - Empty state widgets
- `skeleton_loader.dart` - Loading skeleton widgets

## 🔄 Import Conventions

Always use absolute imports:

```dart
import 'package:expense_tracking_desktop_app/features/expenses/screens/expenses_list_screen.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
```

## 📝 Notes

- **Feature-based architecture**: Each feature in `/features` is self-contained with its own screens, widgets, view models, repositories, and services
- **Generated files**: Files ending with `.g.dart` are auto-generated by build_runner
- **Clean architecture**: The app follows a layered architecture with clear separation between UI, business logic, and data layers
- **Dependency injection**: Riverpod is used for dependency injection and state management
- **Old directories removed**: The legacy `/screens` directory has been removed in favor of the feature-based structure
