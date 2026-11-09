# Testing Guide & Verification Suite — Skill-Link 2.0

## 1. Testing Strategy

Skill-Link includes an automated test suite verifying data serialization, validation logic, role escalation security, and core UI rendering.

```
test/
├── unit/
│   ├── proposal_count_test.dart         # Tests dynamic proposals count, isolation & formatting
│   ├── indian_locations_test.dart       # Tests 28 states, 8 UTs, city maps & custom values
│   ├── model_serialization_test.dart   # Tests UserModel, WorkerModel, JobModel, etc.
│   ├── validators_test.dart             # Tests input validation rules
│   └── role_logic_test.dart             # Tests role switching and anti-escalation
├── widget/
│   ├── indian_location_selector_test.dart # Tests dependent state/city cascading dropdown
│   ├── landing_page_test.dart           # Tests LandingPage layout & desktop/mobile rendering
│   ├── reusable_widgets_test.dart       # Tests AppButton, Badges, RatingStars, EmptyState
│   └── ../widget_test.dart              # App brand smoke test
└── security/
    └── firestore_rules_test.mjs         # 32 automated tests running against Firestore Emulator
```

---

## 2. Executing Automated Tests

Run the full test suite with Flutter:

```bash
flutter test
```

To run a specific test suite:
```bash
# Unit tests
flutter test test/unit/model_serialization_test.dart
flutter test test/unit/validators_test.dart
flutter test test/unit/role_logic_test.dart

# Widget tests
flutter test test/widget/reusable_widgets_test.dart
flutter test test/widget/landing_page_test.dart
```

---

## 3. End-to-End Test Workflow Verification

When connecting to the Firebase Emulator Suite or live Firebase backend, the following 20-step verification flow should be executed:

1. **Register a New User:** Navigate to `/register`, enter name, email, password, and select **Both** (Customer and Worker).
2. **Select Starting Portal:** On the Portal Selection screen, choose **Customer Portal**.
3. **Verify Customer Dashboard:** Confirm personalized greeting and empty state/recommended workers.
4. **Switch to Worker Portal:** Click the top bar "Worker Portal" button.
5. **Complete Worker Onboarding:** Complete professional headline, skills, category (*Electrician*), rate (*₹500/hr*), and city (*Bengaluru*). Click "Save & Publish Profile".
6. **Verify Worker Dashboard:** Check published base rate, active applications counter, and rating badge.
7. **Edit Worker Profile:** Navigate to `/worker/profile/edit`, change rate to *₹550/hr*, and save.
8. **Switch Back to Customer:** Click "Customer Portal" pill in top bar.
9. **Search Workers:** Open Find Workers (`/customer/find-workers`), search by "Electrician", and filter by "Bengaluru".
10. **Bookmark Worker:** Click the bookmark icon on a worker card. Navigate to `/customer/saved-workers` and verify persistence.
11. **Post a Job:** Navigate to `/customer/post-job`. Enter "Ceiling Fan & Wiring Repair", category *Electrician*, budget *₹1200*, city *Bengaluru*. Click "Publish Job Post".
12. **Switch to Worker:** Click "Worker Portal" pill.
13. **Browse Available Jobs:** Open `/worker/browse-jobs`. Verify the newly posted job appears with *₹1200* budget.
14. **Submit Proposal:** Click "Apply Now". Enter proposed rate *₹1100* and a message. Click "Submit Application".
15. **Verify Duplicate Prevention:** Attempt to apply to the same job again. Verify system blocks duplicate bids.
16. **Switch to Customer:** Click "Customer Portal". Open My Posted Jobs (`/customer/my-jobs`).
17. **Review Proposal:** Click "1 Applications" on the job card. View worker details, rate (*₹1100*), and message.
18. **Accept Proposal:** Click "Accept Worker". Verify status updates to *Accepted* and notification is dispatched.
19. **Submit Rating Review:** As customer, open the accepted proposal, click "Write Review", choose 5 stars, enter feedback, and submit. Verify worker's average rating updates.
20. **Sign Out:** Navigate to `/profile` and click "Sign Out". Verify protected routes are inaccessible and redirect to `/login`.

