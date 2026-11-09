# Firestore Data Schema & Architecture — Skill-Link 2.0

## 1. Schema Overview

Cloud Firestore is organized into clear root collections with explicit document ownership and privacy boundaries.

```
/users/{uid}                           # Private user account documents
/workerProfiles/{workerId}             # Publicly discoverable worker profiles
/jobs/{jobId}                          # Customer service requests
/applications/{applicationId}          # Worker proposals on jobs
/savedWorkers/{customerId_workerId}    # Customer bookmarks
/reviews/{reviewId}                    # Public verified customer reviews
/notifications/{notificationId}        # Recipient-specific in-app notifications
```

---

## 2. Collection Specifications

### `users/{uid}`
Private user record holding account metadata and role enrollments.
- `uid`: `string` (Matches Firebase Auth UID)
- `fullName`: `string`
- `email`: `string`
- `photoUrl`: `string?`
- `phone`: `string?`
- `activeRole`: `string` (`'customer'` or `'worker'`)
- `roles`: `array<string>` (Allowed items: `'customer'`, `'worker'`)
- `accountStatus`: `string` (`'active'`, `'suspended'`)
- `createdAt`: `timestamp`
- `updatedAt`: `timestamp`

### `workerProfiles/{workerId}`
Public marketplace profile. Contains craft details and public statistics. Contains **no private contact info** (phone and email remain private in `users/{uid}`).
- `uid`: `string` (Matches Worker UID)
- `fullName`: `string`
- `headline`: `string`
- `description`: `string`
- `skills`: `array<string>`
- `category`: `string`
- `experienceYears`: `number`
- `city`: `string`
- `state`: `string`
- `locality`: `string`
- `rate`: `number`
- `rateType`: `string` (`'hourly'`, `'daily'`, `'fixed'`)
- `availability`: `string`
- `photoUrl`: `string?`
- `portfolioImageUrls`: `array<string>`
- `averageRating`: `number` (Re-computed upon verified review submission)
- `reviewCount`: `number`
- `profileStatus`: `string` (`'completed'`, `'incomplete'`)
- `contactPhone`: `string?` (Displayed only during service coordination)
- `createdAt`: `timestamp`
- `updatedAt`: `timestamp`

### `jobs/{jobId}`
Customer job posts open for worker proposals.
- `customerId`: `string` (Owner UID)
- `customerName`: `string`
- `title`: `string`
- `category`: `string`
- `description`: `string`
- `requiredSkills`: `array<string>`
- `location`: `string`
- `city`: `string`
- `state`: `string`
- `preferredDate`: `string?`
- `budget`: `number`
- `paymentType`: `string` (`'fixed'`, `'hourly'`)
- `additionalInstructions`: `string?`
- `status`: `string` (`'open'`, `'in_progress'`, `'completed'`, `'cancelled'`)
- `applicantCount`: `number`
- `createdAt`: `timestamp`
- `updatedAt`: `timestamp`

### `applications/{applicationId}`
Proposals submitted by workers on customer jobs.
- `jobId`: `string`
- `jobTitle`: `string`
- `customerId`: `string`
- `workerId`: `string`
- `workerName`: `string`
- `workerCategory`: `string`
- `workerPhotoUrl`: `string?`
- `workerAverageRating`: `number`
- `message`: `string`
- `proposedRate`: `number`
- `proposedRateType`: `string`
- `status`: `string` (`'applied'`, `'under_review'`, `'accepted'`, `'rejected'`, `'withdrawn'`)
- `createdAt`: `timestamp`
- `updatedAt`: `timestamp`

### `savedWorkers/{customerId_workerId}`
Deterministic document ID prevents duplicate bookmarks.
- `customerId`: `string`
- `workerId`: `string`
- `createdAt`: `timestamp`

### `reviews/{reviewId}`
Verified feedback left by a customer after job completion.
- `customerId`: `string`
- `customerName`: `string`
- `workerId`: `string`
- `jobId`: `string`
- `jobTitle`: `string`
- `rating`: `number` (1.0 to 5.0)
- `comment`: `string`
- `createdAt`: `timestamp`

### `notifications/{notificationId}`
- `recipientId`: `string`
- `title`: `string`
- `message`: `string`
- `type`: `string` (`'application'`, `'status_update'`, `'review'`, `'general'`)
- `relatedId`: `string?`
- `read`: `boolean`
- `createdAt`: `timestamp`

---

## 3. Composite Indexes (`firestore.indexes.json`)

The following composite queries are configured and indexed for optimal query performance:
1. `jobs`: `category ASC` + `status ASC` + `createdAt DESC`
2. `jobs`: `customerId ASC` + `createdAt DESC`
3. `workerProfiles`: `category ASC` + `averageRating DESC`
4. `workerProfiles`: `category ASC` + `rate ASC`
5. `applications`: `workerId ASC` + `createdAt DESC`
6. `applications`: `customerId ASC` + `createdAt DESC`
7. `notifications`: `recipientId ASC` + `createdAt DESC`
8. `reviews`: `workerId ASC` + `createdAt DESC`
9. `savedWorkers`: `customerId ASC` + `createdAt DESC`
