# Project Architecture — Skill-Link 2.0

## 1. Architectural Philosophy

Skill-Link is designed following a **Feature-Based Modular Clean Architecture** that enforces clear separation of concerns across presentation, business state, domain operations, and infrastructure data services.

```
┌─────────────────────────────────────────────────────────────┐
│                      UI LAYER (Features)                    │
│      Screens, Responsive Shells, Section Widgets, Dialogs   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Observes / Dispatches
┌──────────────────────────────▼──────────────────────────────┐
│                    STATE LAYER (Providers)                  │
│   AuthProvider, CustomerProvider, WorkerProvider,           │
│   JobProvider, ApplicationProvider, NotificationProvider    │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invokes Domain Operations
┌──────────────────────────────▼──────────────────────────────┐
│                  DOMAIN REPOSITORIES LAYER                  │
│   AuthRepository, WorkerRepository, JobRepository,          │
│   ApplicationRepository, ReviewRepository, SavedRepository  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Marshals Data & Models
┌──────────────────────────────▼──────────────────────────────┐
│                   INFRASTRUCTURE SERVICES                   │
│   FirebaseService, AuthService, FirestoreService,           │
│   StorageService, NotificationService                       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Network / SDK Calls
┌──────────────────────────────▼──────────────────────────────┐
│                  FIREBASE CLOUD INFRASTRUCTURE               │
│   Firebase Auth, Cloud Firestore, Firebase Storage, Emulators│
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities

### Presentation Layer (`lib/features/`)
- Contains user-facing screens and modular subcomponents organized by business domain.
- Responsive design via `ResponsiveLayout` and `MaxWidthContainer` adapting dynamically to mobile phones, tablets, and desktop workstations.
- Reusable UI primitives (`AppButton`, `AppTextField`, `AppCard`, `AppAvatar`, `StatusBadge`, `RoleBadge`, `RatingStars`) ensure complete visual and tactile consistency.

### State Management Layer (`lib/providers/`)
- Implemented with Flutter `Provider` (`ChangeNotifier`).
- Encapsulates state mutation logic, handles asynchronous loading flags, and maps errors into human-readable user notices.
- **Key Providers:**
  - `AuthProvider`: Manages authentication state, session restoration, active portal switching, and second-role enrollment.
  - `CustomerProvider`: Manages worker directory queries, search filters, and saved worker collections.
  - `WorkerProvider`: Manages worker profile updates, available job discovery, and job filters.
  - `JobProvider`: Handles customer job creation, lifecycle updates, and status transitions.
  - `ApplicationProvider`: Manages job proposals, duplicate application prevention, and applicant status changes.
  - `NotificationProvider`: Streams in-app alerts and handles read states.

### Repositories Layer (`lib/repositories/`)
- Acts as the single source of truth for business data operations.
- Enforces duplicate application checks, duplicate review prevention, role validation, and rating re-computations before saving to Firestore.
- Decouples the UI and state layers from direct database implementation details.

### Infrastructure Services (`lib/services/`)
- Direct adapters to Firebase SDKs (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`).
- Centralized exception mapping via custom typed classes (`AuthException`, `DatabaseException`, `ValidationException`).
- Integrated emulator redirection support via `USE_EMULATOR` flags.

---

## 3. Unified Account Architecture & Role Security

One of the foundational architectural tenets of Skill-Link is that a single user account can participate in both sides of the marketplace:

1. **Common Authentication:** Every user authenticates through a single Firebase Authentication record.
2. **Account Roles (`roles`):** Stored in `users/{uid}.roles` as a list containing `'customer'`, `'worker'`, or both. Only these two values are permitted. Administrative privileges can never be self-assigned.
3. **Interface Preference (`activeRole`):** Stored in `users/{uid}.activeRole`. Indicates whether the user currently wants to view the Customer Portal or Worker Portal.
4. **Security Enforcement:** The active portal controls only client-side navigation. All actual write and read operations are verified against `roles` and owner IDs in `firestore.rules`.

