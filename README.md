# Skill-Link 2.0

> **Connecting Local Skills with Local Opportunities.**

Skill-Link is a community-focused local skills and employment marketplace that connects people who need services with verified skilled workers who offer those services.

The platform allows **Customers** to discover local craftspeople, post service requirements, hire specialists, and review completed jobs. **Workers** can showcase their craftsmanship, set their own rates, browse client job postings, submit proposals, and manage their applications—with zero predatory platform commission cuts.

---

## Key Highlights

- **Unified Account Model:** One account per user with one common Firebase Authentication system. A user can hold both Customer and Worker capabilities and switch between portals instantly without re-logging.
- **Role-Based Security:** Interface preference (`activeRole`) is strictly separated from actual permissions (`roles`). Access control is enforced via production Firestore Security Rules with no self-assignable administrative rights.
- **Material 3 Design System:** Custom warm, community-oriented visual palette (Deep Forest Teal `#124B45`, Primary Teal `#176B63`, Warm Cream `#FAF8F3`, Terracotta `#C76B4A`, Muted Saffron `#D8A64A`).
- **Responsive Layouts:** Tailored, ergonomic layouts for Mobile (< 600px), Tablet (600–1024px), and Desktop (> 1024px) across Web and Android.
- **Production Backend Stack:** Firebase Authentication, Cloud Firestore, Firebase Storage, and Emulator Suite support.

---

## Repository Structure

```
Skill-Link/
├── lib/
│   ├── main.dart                          # Application entrypoint & Firebase bootstrap
│   ├── app.dart                           # Root MultiProvider & MaterialApp.router
│   ├── firebase_options.dart              # Platform Firebase configurations & placeholders
│   ├── core/
│   │   ├── constants/                     # Colors, string tokens, categories, statuses
│   │   ├── theme/                         # Material 3 ThemeData & typography
│   │   ├── routing/                       # GoRouter configuration & route definitions
│   │   ├── utils/                         # Validators, formatters, responsive utilities
│   │   ├── exceptions/                    # Typed application exception classes
│   │   └── widgets/                       # Buttons, text fields, cards, badges, avatars
│   ├── models/                            # User, Worker, Job, Application, Review, Notification
│   ├── services/                          # Auth, Firestore, Storage, Notifications
│   ├── repositories/                      # Domain repositories with caching & validation
│   ├── providers/                         # ChangeNotifier state management
│   └── features/
│       ├── landing/                       # Public high-priority landing page & sections
│       ├── authentication/                # Login, Register, Password Reset
│       ├── portal_selection/              # EcoCollect-inspired portal switch & enrollment
│       ├── onboarding/                    # Worker professional profile setup
│       ├── customer/                      # Customer dashboard & navigation shell
│       ├── worker/                        # Worker dashboard & navigation shell
│       ├── worker_directory/              # Discovery, filters, sorting, worker profiles
│       ├── jobs/                          # Post job, manage jobs, browse jobs
│       ├── applications/                  # Apply, review proposals, withdraw
│       ├── saved_workers/                 # Customer bookmarks
│       ├── reviews/                       # Authenticated ratings & reviews
│       ├── notifications/                 # In-app notifications
│       ├── profile/                       # Account profile & edit worker profile
│       └── settings/                      # Settings & platform documentation
├── test/
│   ├── unit/                              # Validators, models, role logic tests
│   └── widget/                            # Landing page, core widgets, smoke tests
├── firestore.rules                        # Production Firestore Security Rules
├── firestore.indexes.json                 # Composite queries index specifications
├── storage.rules                          # Firebase Storage access rules
├── firebase.json                          # Firebase Emulator Suite & project configuration
└── .env.example                           # Environment configuration template
```

---

## Quick Start Commands

### 1. Prerequisites
- Flutter SDK 3.22+ / 3.41+
- Dart SDK 3.4+ / 3.11+
- Chrome or Edge browser (for Web)
- Android Studio / Android SDK (for Android builds)
- Firebase CLI (`npm install -g firebase-tools`)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Code Analysis
```bash
flutter analyze
```

### 4. Run Automated Tests
```bash
flutter test
```

### 5. Run Web Locally
```bash
flutter run -d chrome
```

### 6. Build Production Web Release
```bash
flutter build web
```

---

## Documentation Index

1. [`PROJECT_ARCHITECTURE.md`](PROJECT_ARCHITECTURE.md) — Architectural patterns, layers, and Provider state management.
2. [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) — Step-by-step Firebase configuration guide & credential setup.
3. [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md) — Collections, schemas, relationships, and indexes.
4. [`SECURITY_RULES.md`](SECURITY_RULES.md) — Security model, data validation, and permission enforcement.
5. [`NAVIGATION_FLOW.md`](NAVIGATION_FLOW.md) — Centralized routing matrix, route guards, and portal transitions.
6. [`FEATURES.md`](FEATURES.md) — Detailed feature list across Customer, Worker, and Shared domains.
7. [`TESTING_GUIDE.md`](TESTING_GUIDE.md) — Unit tests, widget tests, and emulator test procedures.
8. [`DEVELOPMENT_SETUP.md`](DEVELOPMENT_SETUP.md) — Local development environment setup & emulator instructions.
9. [`KNOWN_LIMITATIONS.md`](KNOWN_LIMITATIONS.md) — Production considerations, limitations, and future roadmap.
