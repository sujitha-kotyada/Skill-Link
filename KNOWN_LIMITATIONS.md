# Known Limitations & Production Roadmap — Skill-Link 2.0

## 1. Current Architecture Considerations

### A. Firebase Cloud Messaging (FCM)
- In-app notification streaming via Cloud Firestore (`/notifications/{notificationId}`) is fully operational.
- Native background push notifications using Firebase Cloud Messaging require platform-specific certificates (APNs for iOS, Firebase Console Server Key / FCM V1 API credentials for Android/Web), which must be configured directly in your Firebase Console.

### B. Image Uploads on Web & Android
- The Firebase Storage service structure and rules (`storage.rules`) are fully configured.
- When running in an environment without a configured live Firebase Storage bucket, worker avatars and portfolio displays gracefully fallback to localized initial avatars and icons without throwing uncaught exceptions.

### C. Geolocation Proximity vs City Filtering
- Worker and job discovery currently uses indexed textual matching on City and Locality.
- For fine-grained GPS kilometer radius calculations, integrating Geohashing (`geoflutterfire` or server-side Cloud Functions) can be added as an optional enhancement.

### D. Payment Gateways
- Skill-Link currently operates on a direct-negotiation, zero-commission community marketplace model where customers pay workers directly upon job completion.
- If in-app escrow or payment processing is desired in future releases, a payment gateway SDK (such as Razorpay or Stripe) can be integrated with Cloud Functions handling webhook verification.

---

## 2. Production Deployment Checklist

Prior to launching to public end users:
1. [ ] Run `flutterfire configure` to generate production Firebase credentials in `lib/firebase_options.dart`.
2. [ ] Deploy Firestore Security Rules: `firebase deploy --only firestore:rules`.
3. [ ] Deploy Firestore Indexes: `firebase deploy --only firestore:indexes`.
4. [ ] Deploy Storage Rules: `firebase deploy --only storage`.
5. [ ] Provide `android/app/google-services.json` if releasing an Android APK.
6. [ ] Deploy web build (`build/web`) to Firebase Hosting or your CDN of choice.

