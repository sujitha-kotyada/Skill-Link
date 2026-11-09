class RouteNames {
  static const String splash = '/splash';
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String portalSelect = '/portal-select';
  static const String roleEnroll = '/role-enroll';
  static const String authError = '/auth-error';

  // Worker Onboarding
  static const String workerOnboarding = '/worker/onboarding';

  // Customer Portal
  static const String customerDashboard = '/customer/dashboard';
  static const String customerFindWorkers = '/customer/find-workers';
  static const String customerWorkerDetail = '/customer/workers/:id';
  static const String customerSavedWorkers = '/customer/saved-workers';
  static const String customerJobs = '/customer/my-jobs';
  static const String customerPostJob = '/customer/post-job';
  static const String customerJobDetail = '/customer/jobs/:id';
  static const String customerJobApplications = '/customer/jobs/:id/applications';

  // Worker Portal
  static const String workerDashboard = '/worker/dashboard';
  static const String workerBrowseJobs = '/worker/browse-jobs';
  static const String workerJobDetail = '/worker/jobs/:id';
  static const String workerApplyJob = '/worker/apply-job/:id';
  static const String workerApplications = '/worker/my-applications';
  static const String workerProfile = '/worker/profile';
  static const String workerEditProfile = '/worker/profile/edit';

  // Shared
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String writeReview = '/reviews/write';
}

