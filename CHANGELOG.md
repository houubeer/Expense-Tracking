# Changelog

All notable changes to the Expense Tracking Desktop App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-30

### 🎉 Initial Release

First production release of the Expense Tracking Desktop App for small businesses.

### ✨ Features

#### Expense Management

- Create, read, update, and delete expenses
- Categorize expenses with custom categories
- Date-based expense tracking
- Search and filter expenses by description, category, and date
- View expense history with category details
- Automatic category budget updates on expense changes

#### Budget Management

- Create and manage budget categories
- Set spending limits for each category
- Real-time budget tracking with spent amounts
- Visual budget health indicators (healthy, warning, exceeded)
- Customizable category colors and icons
- Automatic budget calculations

#### Dashboard & Analytics

- Real-time financial overview
- Total budget vs. total spent visualization
- Budget remaining with percentage indicators
- Category-wise spending breakdown
- Recent expenses widget
- Visual charts for spending analysis
- Budget health status with color-coded indicators

#### Data Persistence

- SQLite database with Drift ORM integration
- Type-safe database operations
- Schema version management (v1 to v5)
- Database migrations support
- Foreign key constraints with CASCADE delete
- Database health checks and recovery mechanisms
- Optimistic locking for concurrent modifications

#### Cross-Platform Support

- Windows desktop build
- macOS desktop build
- Linux desktop build
- Platform-specific database connections
- Native look and feel on each platform

#### Architecture & Code Quality

- Clean layered architecture (UI → ViewModel → Service → Repository → DAO)
- Dependency injection with Riverpod
- Interface-based abstractions for testability
- Transaction safety for multi-step operations
- Comprehensive error handling
- Custom exceptions (DatabaseException, ValidationException)

#### Logging & Monitoring

- Comprehensive logging system with LoggerService
- Multiple log levels (debug, info, warning, error)
- Error reporting with stack traces and context
- File-based log output
- Connectivity service for future cloud sync
- Detailed operation logging across all layers

#### Testing

- Unit tests for DAOs, services, and repositories
- Integration tests for complete user flows
- In-memory database for test isolation
- Test coverage reporting
- Mock implementations for testing

#### Documentation

- Comprehensive README with setup instructions
- Architecture overview with diagrams
- Database schema documentation
- API documentation with DartDocs (10/10 rating)
- Logging implementation guide
- Project structure documentation
- Troubleshooting guide
- CHANGELOG for version tracking
- Deliverable summary document

### 🗄️ Database Schema

#### Tables

- **Categories** (v1)
  - Fields: id, name, color, iconCodePoint, budget, spent, version, createdAt
  - Indices: Primary key on id
- **Expenses** (v2)
  - Fields: id, amount, date, description, categoryId, createdAt
  - Indices: Primary key on id, date, categoryId
  - Foreign Keys: categoryId → categories(id) ON DELETE CASCADE

#### Migrations

- v1: Initial categories table
- v2: Added expenses table
- v3: Added color and icon fields to categories
- v4: Added version column for optimistic locking
- v5: Added createdAt timestamp to expenses

### 🔧 Technical Details

#### Dependencies

- Flutter 3.0+
- Dart 3.0+
- Drift (latest) - ORM for SQLite
- Riverpod (latest) - State management
- fl_chart (latest) - Data visualization
- logger (latest) - Logging infrastructure
- connectivity_plus (latest) - Network monitoring
- path_provider (latest) - File system access
- path (latest) - Path manipulation

#### Build Tools

- build_runner - Code generation
- drift_dev - Drift code generation

### 🐛 Bug Fixes

- Fixed missing version parameter in ExpenseService.updateCategorySpent calls (5 instances)
- Fixed duplicate method declaration in AppDatabase.attemptRecovery
- Fixed concurrent modification handling with optimistic locking
- Fixed foreign key constraint violations with proper cascade deletes
- Fixed database health check integrity verification

### 🔒 Security

- Local-only data storage (no cloud transmission)
- SQLite database with file-system permissions
- Transaction safety prevents data corruption
- Optimistic locking prevents concurrent modification conflicts
- Input validation across all layers

### 📝 Code Quality

- All classes documented with comprehensive DartDocs
- All public methods have parameter and return documentation
- Usage examples provided for complex operations
- Architecture diagrams included in documentation
- Clean code principles applied throughout
- SOLID principles adherence

### 🎨 UI/UX

- Material Design 3 implementation
- Responsive layouts for desktop
- Custom color schemes (light mode)
- Interactive charts and visualizations
- Intuitive navigation with sidebar
- Real-time data updates with streams
- Loading states and error handling
- Empty states with helpful messages

### ⚡ Performance

- Indexed database queries for fast lookups
- Stream-based reactive updates
- Efficient widget rebuilds with Riverpod
- VACUUM and REINDEX for database optimization
- Lazy loading where appropriate

### 🧪 Testing Coverage

- Unit tests: ✅

  - CategoryDao operations
  - ExpenseDao operations
  - Repository layer mapping
  - Service layer business logic
  - ViewModel state management

- Integration tests: ✅
  - Complete expense creation flow
  - Category budget update flow
  - Database migration scenarios
  - Concurrent modification handling

### 📦 Build Outputs

- **Windows**: `build/windows/runner/Release/`
- **macOS**: `build/macos/Build/Products/Release/`
- **Linux**: `build/linux/x64/release/bundle/`

### 🚀 Installation

```bash
# Clone repository
git clone https://github.com/houubeer/Expense-Tracking

# Install dependencies
flutter pub get

# Generate Drift code
dart run build_runner build

# Run application
flutter run -d windows  # or macos, linux
```

### 📖 Documentation Links

- [README.md](README.md) - Project documentation
- [DELIVERABLE_SUMMARY.md](DELIVERABLE_SUMMARY.md) - Project overview
- [docs/LOGGING_IMPLEMENTATION.md](docs/LOGGING_IMPLEMENTATION.md) - Logging details
- [lib/STRUCTURE.md](lib/STRUCTURE.md) - Project structure

### 🙏 Contributors

- **Beradai Houssameddine Diaelhak** ([@houubeer](https://github.com/houubeer))
- **Cilia Mouhoun** ([@cilia-mouhoun](https://github.com/cilia-mouhoun))
- **Mohamed Islam Sahli** ([@Mohamedislam19](https://github.com/Mohamedislam19))
- **Aya Brahimi** ([@Aya-Brahimi](https://github.com/Aya-Brahimi))
- **Enzo Chaabnia** ([@ENZOdz23](https://github.com/ENZOdz23))

---

## [Unreleased]

### 🚧 Planned Features

#### v1.1.0 (Q1 2026)

- [ ] Cloud synchronization (Google Drive, Dropbox)
- [ ] Receipt image attachments
- [ ] PDF/Excel report export
- [ ] Multi-currency support
- [ ] Recurring expense templates
- [ ] Dark mode theme
- [ ] Advanced search with filters
- [ ] Budget forecasting

#### v1.2.0 (Q2 2026)

- [ ] Mobile app (iOS/Android)
- [ ] Data import/export (CSV, JSON)
- [ ] Custom report builder
- [ ] Budget alerts and notifications
- [ ] Expense categories hierarchy
- [ ] Tags for expenses
- [ ] Bulk operations

#### v2.0.0 (Q3 2026)

- [ ] Multi-user support
- [ ] Role-based access control
- [ ] Cloud-native architecture
- [ ] Real-time collaboration
- [ ] Advanced analytics dashboard
- [ ] API for third-party integrations
- [ ] Mobile web version

### 🐛 Known Issues

- Optimistic locking requires manual retry on conflict (automatic retry planned for v1.1.0)
- No cloud backup in v1.0.0 (planned for v1.1.0)
- Limited to single user per database (multi-user planned for v2.0.0)

---

## Version History Summary

| Version | Release Date | Status      | Highlights                              |
| ------- | ------------ | ----------- | --------------------------------------- |
| 1.0.0   | 2025-11-30   | ✅ Released | Initial production release              |
| 1.1.0   | Q1 2026      | 🚧 Planned  | Cloud sync, receipts, export            |
| 1.2.0   | Q2 2026      | 🚧 Planned  | Mobile app, import/export               |
| 2.0.0   | Q3 2026      | 🚧 Planned  | Multi-user, cloud-native, collaboration |

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/) conventions:

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

[1.0.0]: https://github.com/houubeer/Expense-Tracking/releases/tag/v1.0.0
[Unreleased]: https://github.com/houubeer/Expense-Tracking/compare/v1.0.0...HEAD
