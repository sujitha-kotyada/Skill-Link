# Platform Features Catalog — Skill-Link 2.0

## 1. Landing Page (Public High Priority)
- **Branded Header:** Responsive navigation bar with direct links to Home, Find Workers, How It Works, About, Sign In, and Get Started.
- **Hero Section:** Headline: *"Local Skills. Real Opportunities. Stronger Communities."*, supporting copy, Primary CTA (*Find Skilled Workers*), Secondary CTA (*Offer Your Skills*), and trust indicators.
- **Popular Categories:** Interactive grid covering all 11 core trades (Electrician, Plumber, Carpenter, Painter, Mechanic, Tailor, Tutor, Cleaning Services, Appliance Repair, Gardening, Other Skills). Clicking any card navigates directly to the directory with the category pre-filtered.
- **How It Works:** Three-step visual workflow (Find or Post, Connect Directly, Complete & Review).
- **The Skill-Link Advantage:** Highlights direct customer negotiations, zero commission deductions, and audited community reviews.
- **Explore Skilled Professionals:** Sample artisan cards with ratings, skills, and rates.
- **Worker Growth Hub:** Value proposition for skilled craftspeople to build an independent career.
- **Community Impact:** Transparent platform benchmarks and metrics.
- **Testimonials:** Verified neighborhood stories from both customers and workers.
- **Final CTA & Footer:** Bottom call-to-action banner and extensive multi-column footer with copyright and navigation links.

---

## 2. Common Authentication & Identity
- **Unified Account:** A single email/password login supports Customer, Worker, or Both roles simultaneously.
- **Registration Form:** Full name, email, password strength checks, confirm password validation, terms acceptance, and multi-role selection.
- **Login Form:** Clean EcoCollect-inspired form with password visibility toggling and error handling.
- **Forgot Password:** Secure password reset email dispatch via Firebase Authentication.
- **Session Persistence:** Authenticated sessions persist across browser refreshes and app restarts.

---

## 3. Portal Selection & Role Switching
- **EcoCollect Reference UI:** Dedicated welcome screen displaying large portal cards with custom role descriptions.
- **Instant Role Switch:** Users with dual roles can switch active portals anytime with one click in the top app bar or profile screen.
- **Safe Role Enrollment:** Users with one role can activate the second role through `RoleEnrollmentScreen` without losing existing profile data.
- **Self-Service Restrictions:** Only `'customer'` and `'worker'` are self-enrolled. Admin permissions can never be assigned by users.

---

## 4. Customer Portal
- **Dashboard:** Personalized greeting, quick search bar, quick action cards (*Post Job*, *Find Workers*, *Saved Workers*), horizontal category chips, active job status cards, and recommended artisans.
- **Find Workers:** Full-featured directory with search by name, skill, or keyword; category filtering; city filtering; budget slider; minimum rating selector; and sorting (*Highest Rated*, *Price: Low to High*, *Most Experienced*).
- **Worker Profile Detail:** Public craft bio, headline, experience years, skills tags, hourly/daily rate, availability status, client reviews list, and bookmarking.
- **Contact Workflow:** Privacy-safe contact dialog that preserves phone number confidentiality until explicit service coordination.
- **Saved Workers:** Persistent bookmarking stored in Firestore with real-time toggle.
- **Post a Job:** Comprehensive form capturing title, category, budget, payment type (*Fixed* / *Hourly*), location, required skills, timeline, and instructions.
- **Customer Job Management:** Filter by status (*Open*, *In Progress*, *Completed*, *Cancelled*), view applicant counts, mark completed, or cancel.
- **Application Review:** Review submitted worker proposals, read proposal notes, inspect proposed pricing, and click *Accept* or *Reject*.
- **Verified Customer Reviews:** Post star ratings (1 to 5) and written feedback for workers on completed jobs with duplicate review prevention.

---

## 5. Worker Portal
- **Worker Onboarding:** Guided setup collecting professional headline, trade category, experience, city, locality, base rate, availability, specialized skill tags, bio, and contact preferences.
- **Worker Dashboard:** Welcome banner, profile rating, active applications counter, accepted jobs counter, base rate display, and available opportunities feed.
- **Browse Jobs:** Search and filter client-posted jobs by category, city, and minimum budget.
- **Job Proposal Submission:** Apply with custom proposed pricing (*Fixed* or *Hourly*) and cover note. Built-in duplicate application check prevents duplicate bids.
- **My Applications Tracker:** Status tabs (*Applied*, *Under Review*, *Accepted*, *Rejected*, *Withdrawn*) with proposal withdrawal capability.
- **Worker Profile Management:** Edit rates, skills, location, and bio at any time.

---

## 6. Shared Infrastructure
- **In-App Notifications:** Real-time updates delivered to Firestore and displayed with unread badges when proposals are submitted, accepted, or reviewed.
- **Centralized Error Handling:** User-friendly snackbars and error banners with zero raw stack traces exposed.
- **Performance:** Firestore queries are limited and indexed to prevent excessive reads and eliminate memory bloat.

