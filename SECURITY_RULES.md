# Security Rules & Permission Architecture — Skill-Link 2.0

## 1. Security Architecture Principles

1. **Server-Enforced Access Control:** Client-side route guards prevent UI flicker, but Firestore Security Rules (`firestore.rules`) and Storage Rules (`storage.rules`) provide the authoritative boundary.
2. **Strict Field Validation:** Writes require all mandatory fields, enforce correct data types (numbers, lists, timestamps), and enforce value boundaries (e.g. `rating >= 1 && rating <= 5`, `budget >= 0`).
3. **No Self-Privilege Escalation:** Self-assigning `'admin'` or arbitrary role flags is strictly blocked at the security rule level.
4. **Public vs. Private Separation:** Sensitive user data (email, password hash, private contact flags) lives strictly in `users/{uid}`, readable only by the owner. Public worker profiles in `workerProfiles/{workerId}` contain only approved public craft credentials.

---

## 2. Firestore Security Rules Breakdown

### `users/{userId}`
- **Read:** `isOwner(userId)` — Only the owner can read their private profile document.
- **Create:** `isOwner(userId)` — User can create their initial profile upon registration. Must have valid `roles` (`hasOnly(['customer', 'worker'])`) and cannot contain `isAdmin == true`.
- **Update:** `isOwner(userId)` — User can update their name, phone, or active role preference. Cannot change `email` or grant themselves unauthorized roles.
- **Delete:** Denied.

### `workerProfiles/{workerId}`
- **Read:** `true` — Publicly discoverable by any client (including unauthenticated landing page visitors).
- **Create:** `isOwner(workerId) && hasRole('worker')` — User must own the ID and have enrolled in the `'worker'` role.
- **Update:** `isOwner(workerId)` — Worker can update craft information, but `averageRating` and `reviewCount` are protected against direct client modification.
- **Delete:** `isOwner(workerId)`.

### `jobs/{jobId}`
- **Read:** Authenticated users.
- **Create:** `isAuthenticated() && hasRole('customer') && customerId == request.auth.uid`. Budget must be >= 0.
- **Update:** Only the customer owner can update job details or transition status.
- **Delete:** Only the customer owner can delete their job.

### `applications/{applicationId}`
- **Read:** The worker who submitted the proposal OR the customer who posted the parent job.
- **Create:** Verified worker (`hasRole('worker') && workerId == request.auth.uid`).
- **Update:**
  - The worker can change status to `'withdrawn'`.
  - The customer can change status to `'accepted'`, `'rejected'`, or `'under_review'`.
- **Delete:** Worker owner only.

### `savedWorkers/{docId}`
- **Read:** Customer owner only.
- **Create:** Customer owner only; customer cannot bookmark themselves.
- **Delete:** Customer owner only.

### `reviews/{reviewId}`
- **Read:** Public (`true`) to allow community visibility.
- **Create:** Verified customer (`hasRole('customer') && customerId == request.auth.uid`). Cannot review oneself (`customerId != workerId`). Rating must be between 1 and 5.
- **Update / Delete:** Denied. Reviews are immutable historical records.

### `notifications/{notificationId}`
- **Read / Update / Delete:** Strictly recipient owner (`recipientId == request.auth.uid`).

---

## 3. Storage Security Rules Breakdown

`storage.rules`:
- Maximum file size: **5 MB**.
- Content type: Strictly **images only** (`request.resource.contentType.matches('image/.*')`).
- File paths:
  - `workers/{workerId}/**` — Writable only by `request.auth.uid == workerId`. Publicly readable.
  - `users/{userId}/**` — Writable only by `request.auth.uid == userId`. Publicly readable.

