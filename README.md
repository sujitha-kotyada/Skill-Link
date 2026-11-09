# Skill-Link 2.0

> **Connecting Local Skills with Local Opportunities.**

Skill-Link is a community-focused local skills and employment marketplace that connects people who need home and commercial services with verified, skilled local craftspeople.

The platform provides a dual-portal experience for **Customers** and **Workers** backed by a unified account model, robust role-based access control, responsive Material 3 design, and Google Firebase backend infrastructure.

---

## 1. Project Objective

In traditional service platforms, middleman commissions, opaque fee structures, and fragmented communication channels create friction between customers and local workers. Skill-Link eliminates these barriers:
- **Zero Commission Friction:** Customers and local service providers communicate and negotiate directly.
- **Unified Identity:** A single login allows users to act as a customer needing a service, a skilled worker offering expertise, or both—with instantaneous portal switching without re-authenticating.
- **Local Geographic Precision:** Built-in dependent selection across all 28 Indian States and 8 Union Territories with major cities and districts.
- **Enterprise-Grade Security:** Hardened Firestore security rules enforce strict tenant isolation, anti-tampering guards on ratings/reviews, and role validation.

---

## 2. Main Features

### 🌟 Unified Account & Multi-Role Switching
- Single Firebase Authentication session per user.
- Users can hold both `customer` and `worker` roles simultaneously.
- Quick portal switcher in the navigation bar toggles between portals without logging out.
- Interface preference (`activeRole`) is strictly decoupled from permissions (`roles`).

### 👤 Customer Experience
- **Worker Discovery:** Search and browse verified local professionals with category filters, city/district filters, minimum ratings, and hourly/fixed rates.
- **Worker Profiles:** View verified craftsperson profiles, bio headlines, skill tags, experience years, portfolio photos, ratings, and customer reviews.
- **Saved Workers:** Bookmark and organize favorite local craftspeople for quick access.
- **Job Posting:** Multi-field requirement publisher with category selection, budget estimation, payment type (Fixed vs Hourly), locality, and dependent Indian State & City dropdowns.
- **Proposal Review:** View worker proposals in real-time, inspect worker profile snapshots, and accept or reject bids.
- **Job Lifecycle:** Track posted jobs from `open` to `in_progress`, `completed`, or `cancelled`.
- **Reviews & Ratings:** Leave immutable star ratings and written feedback after service completion.

### 🔨 Worker Experience
- **Professional Onboarding:** Multi-step onboarding to establish professional headline, trade category (Electrician, Plumber, Carpenter, Painter, Mason, Cleaner, etc.), experience years, base rates, availability, and location.
- **Profile Customization:** Edit and update professional profile, skills, rates, and availability at any time.
- **Job Discovery:** Browse active client requirements with budget, timeline, locality, and description details.
- **Proposal Submission:** Apply directly with custom pitch messages, proposed rates, and timeline commitments. Duplicate submission guards prevent accidental re-applications.
- **Application Tracking:** Track application status in real-time through `applied`, `under_review`, `accepted`, `rejected`, or `withdrawn`.
- **Proposal Withdrawal:** Safely withdraw submitted proposals if schedule or availability changes.

### 🔔 Real-Time Notifications
- Instant in-app notifications generated upon key lifecycle events (new proposal submitted, proposal accepted, proposal rejected, new review posted).
- Live unread notification counter badge displayed directly in the navigation bar.
- Interactive notification cards: tapping a notification automatically marks it as read and deep-links the user to the relevant job proposals or applications screen.

### 📍 Indian State & City Dependent Dropdowns
- Centralized dataset covering all **28 Indian States** and **8 Union Territories** with comprehensive city listings.
- Dependent cascading selector widget (`IndianLocationSelector`) where City is dynamically populated based on the selected State.
- Backward compatibility: preserves legacy and custom locations without duplicate dropdown entries or assertion errors.
- Responsive design: side-by-side Row on desktop/tablet ($\ge 520\text{px}$) and stacked Column on mobile.

### 📊 Real-Time Dynamic Proposal Counters
- Dynamic single-source-of-truth proposal counter derived from live `applications` Firestore streams.
- Accurate singular/plural formatting across all screens (`0 Proposals`, `1 Proposal`, `5 Proposals`).
- Consistent counts across Customer Dashboard, My Posted Jobs, and Job Details screens.
- Automatically decrements when a proposal is withdrawn.

---

## 3. Technology Stack

- **Framework:** [Flutter](https://flutter.dev) (v3.22+ / v3.41+)
- **Language:** [Dart](https://dart.dev) (v3.4+ / v3.11+)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `MultiProvider`)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) with centralized route definitions and role-aware navigation guards
- **Design System:** Material 3 with Skill-Link community palette:
  - Deep Forest Teal (`#124B45`)
  - Primary Teal (`#176B63`)
  - Warm Cream (`#FAF8F3`)
  - Terracotta (`#C76B4A`)
  - Muted Saffron (`#D8A64A`)
- **Backend & Cloud Services:**
  - **Firebase Authentication:** Email/password authentication with registration auto-signout and email-preserved login.
  - **Cloud Firestore:** Real-time NoSQL database with collection schema rules and composite indexes.
  - **Firebase Storage:** Secure cloud asset storage for profile and portfolio photos.
  - **Firebase Emulator Suite:** Local emulation for Auth (9099), Firestore (8080), and Storage (9199).

---

## 4. Repository Structure

```
Skill-Link/
├── lib/
│   ├── main.dart                          # App initialization & Firebase bootstrap
│   ├── app.dart                           # MultiProvider setup & GoRouter root
│   ├── firebase_options.dart              # Client platform configuration
│   ├── core/
│   │   ├── constants/                     # Colors, Indian locations, strings, categories
│   │   ├── exceptions/                    # Typed exception classes
│   │   ├── routing/                       # GoRouter configuration & route guards
│   │   ├── theme/                         # Material 3 ThemeData & typography
│   │   ├── utils/                         # Validators, formatters, responsive layout
│   │   └── widgets/                       # Reusable UI widgets & IndianLocationSelector
│   ├── models/                            # User, Worker, Job, Application, Review, Notification
│   ├── services/                          # Auth, Firestore, Storage, Notifications
│   ├── repositories/                      # Domain repositories & data access layer
│   ├── providers/                         # State providers (Auth, Job, Customer, App, Worker)
│   └── features/
│       ├── landing/                       # Public landing page with features & directory preview
│       ├── authentication/                # Login, Register, Forgot Password
│       ├── portal_selection/              # Role selector & capability enrollment
│       ├── onboarding/                    # Worker onboarding workflow
│       ├── customer/                      # Customer dashboard, navigation shell
│       ├── worker/                        # Worker dashboard, navigation shell
│       ├── worker_directory/              # Public & customer worker search & discovery
│       ├── jobs/                          # Post job, browse jobs, customer jobs, job details
│       ├── applications/                  # Submit proposal, review proposals, my applications
│       ├── notifications/                 # In-app notifications list & deep-link routing
│       ├── saved_workers/                 # Customer bookmarks
│       ├── reviews/                       # Write review dialog & review display
│       ├── profile/                       # Account profile & edit worker profile
│       └── settings/                      # Platform settings & documentation viewer
├── test/
│   ├── unit/                              # 58 unit tests (locations, proposals, auth, models)
│   ├── widget/                            # 19 widget tests (locations, landing, login, smoke)
│   └── security/
│       └── firestore_rules_test.mjs       # 32 security tests running against Firestore Emulator
├── firestore.rules                        # Production Firestore security rules
├── firestore.indexes.json                 # Firestore composite indexes
├── storage.rules                          # Firebase Storage access rules
├── firebase.json                          # Firebase Emulator & project configuration
├── .firebaserc                            # Firebase project target (skill-link-2de23)
├── .env.example                           # Template for local environment settings
└── .gitignore                             # Hardened Git ignore configuration
```

---

## 5. Local Setup & Execution Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22+ recommended)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Node.js](https://nodejs.org) (v18+ for running Firebase emulators and security tests)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- Google Chrome or Microsoft Edge (for Web development)

### 1. Clone the Repository
```bash
git clone https://github.com/sujitha-kotyada/Skill-Link.git
cd Skill-Link
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase Credentials
Skill-Link comes pre-configured with platform client configuration in `lib/firebase_options.dart`.
If you wish to link your own Firebase project:
```bash
flutterfire configure
```
Copy `.env.example` to `.env` if custom environment overrides are needed:
```bash
cp .env.example .env
```

### 4. Run Static Code Analysis
Ensure zero compilation warnings or lint issues:
```bash
flutter analyze
```

### 5. Run Automated Tests
Execute the complete Flutter unit and widget test suite:
```bash
flutter test
```

### 6. Run Security Rules Suite (Local Emulator)
Start the Firestore emulator and run the 32 automated security assertions:
```bash
firebase emulators:exec "node test/security/firestore_rules_test.mjs" --only firestore
```

### 7. Run the Application Locally

#### Web (Chrome):
```bash
flutter run -d chrome
```

#### Windows Desktop:
```bash
flutter run -d windows
```

#### Android:
```bash
flutter run -d android
```

### 8. Build Production Release (Web)
```bash
flutter build web --release
```
The optimized build output will be placed in `build/web/` and can be served locally or deployed to Firebase Hosting, Cloudflare Pages, or Netlify:
```bash
python -m http.server 5000 --directory build/web
```

---

## 6. Security & Data Protection

- **Tenant Isolation:** Firestore security rules ensure customers can only read and modify their own jobs, applications, notifications, and profile data.
- **Rating Anti-Tampering:** Workers are cryptographically barred from directly modifying their own `averageRating` or `reviewCount`. Ratings are calculated from customer reviews.
- **No Committed Secrets:** Private signing keys, service-account JSON files, and local `.env` files are strictly excluded via `.gitignore`.
- **Public vs Private Credentials:** Public Firebase web configuration tokens are distinguished from private server credentials; no administrative service accounts are bundled in the client application.

---

## 7. License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
