import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/applications/screens/apply_job_screen.dart';
import '../../features/applications/screens/job_applications_screen.dart';
import '../../features/applications/screens/my_applications_screen.dart';
import '../../features/authentication/screens/auth_error_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/customer/screens/customer_dashboard_screen.dart';
import '../../features/customer/screens/customer_shell_screen.dart';
import '../../features/jobs/screens/browse_jobs_screen.dart';
import '../../features/jobs/screens/customer_jobs_screen.dart';
import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/jobs/screens/post_job_screen.dart';
import '../../features/landing/screens/landing_page.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/worker_onboarding_screen.dart';
import '../../features/portal_selection/screens/portal_selection_screen.dart';
import '../../features/portal_selection/screens/role_enrollment_screen.dart';
import '../../features/profile/screens/edit_worker_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reviews/screens/write_review_screen.dart';
import '../../features/saved_workers/screens/saved_workers_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/worker/screens/worker_dashboard_screen.dart';
import '../../features/worker/screens/worker_shell_screen.dart';
import '../../features/worker_directory/screens/find_workers_screen.dart';
import '../../features/worker_directory/screens/worker_detail_screen.dart';
import '../../models/job_model.dart';
import '../../models/worker_model.dart';
import '../../providers/auth_provider.dart';
import 'route_names.dart';

class AppRouter {
  static String? evaluateRouteProtection({
    required AuthProvider authProvider,
    required String location,
    String? redirectParam,
  }) {
    final status = authProvider.status;
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.currentUser;

    // 1. Initial Loading / Splash state: Hold at splash screen while auth resolves
    if (status == AuthStatus.uninitialized || status == AuthStatus.loading) {
      if (location == RouteNames.splash || location == RouteNames.landing) return null;
      return RouteNames.splash;
    }

    // 2. Recoverable error states (networkError, profileMissing, accountSuspended, permissionDenied)
    if (status == AuthStatus.networkError ||
        status == AuthStatus.profileMissing ||
        status == AuthStatus.accountSuspended ||
        status == AuthStatus.permissionDenied) {
      if (location == RouteNames.authError) return null;
      if (location == RouteNames.landing ||
          location.startsWith(RouteNames.login) ||
          location == RouteNames.register ||
          location == RouteNames.forgotPassword) {
        return null;
      }
      return RouteNames.authError;
    }

    // Public allowed routes - ONLY landing, login, register, forgot-password, splash
    final isAuthRoute = location.startsWith(RouteNames.login) ||
        location == RouteNames.register ||
        location == RouteNames.forgotPassword;
    final isPublicRoute = location == RouteNames.landing || isAuthRoute || location == RouteNames.splash;

    // 3. Unauthenticated access protection:
    // Any protected route (including /customer/find-workers, dashboard, etc.) redirects to Login
    if (!isAuthenticated) {
      if (isPublicRoute) return null;
      return '${RouteNames.login}?redirect=${Uri.encodeComponent(location)}';
    }

    // 4. Authenticated user visiting auth routes (login/register)
    if (isAuthRoute) {
      return authProvider.determineInitialRoute(redirectUrl: redirectParam);
    }

    // 5. Authenticated user visiting splash
    if (location == RouteNames.splash) {
      return authProvider.determineInitialRoute();
    }

    // 6. Role-based private access enforcement
    if (user != null) {
      final hasCustomer = user.roles.contains(AppConstants.roleCustomer);
      final hasWorker = user.roles.contains(AppConstants.roleWorker);

      // All /customer/ routes are strictly for accounts with customer role
      if (location.startsWith('/customer/')) {
        if (!hasCustomer) {
          return RouteNames.workerDashboard;
        }
      }

      // All /worker/ routes are strictly for accounts with worker role
      if (location.startsWith('/worker/')) {
        if (!hasWorker) {
          return RouteNames.customerDashboard;
        }
        if (!authProvider.isWorkerOnboarded && location != RouteNames.workerOnboarding) {
          return RouteNames.workerOnboarding;
        }
      }
    }

    return null;
  }

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RouteNames.landing,
      refreshListenable: authProvider,
      redirect: (context, state) {
        return evaluateRouteProtection(
          authProvider: authProvider,
          location: state.uri.toString(),
          redirectParam: state.uri.queryParameters['redirect'],
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.landing,
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) {
            final email = state.extra as String? ?? state.uri.queryParameters['email'];
            return LoginScreen(initialEmail: email);
          },
        ),
        GoRoute(
          path: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RouteNames.authError,
          builder: (context, state) => const AuthErrorScreen(),
        ),
        GoRoute(
          path: RouteNames.portalSelect,
          builder: (context, state) => const PortalSelectionScreen(),
        ),
        GoRoute(
          path: RouteNames.roleEnroll,
          builder: (context, state) {
            final target = state.extra as String? ?? AppConstants.roleWorker;
            return RoleEnrollmentScreen(targetRole: target);
          },
        ),
        GoRoute(
          path: RouteNames.workerOnboarding,
          builder: (context, state) => const WorkerOnboardingScreen(),
        ),

        // Shared routes
        GoRoute(
          path: RouteNames.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.writeReview,
          builder: (context, state) {
            final jobId = state.uri.queryParameters['jobId'] ?? '';
            final workerId = state.uri.queryParameters['workerId'] ?? '';
            final jobTitle = state.uri.queryParameters['jobTitle'] ?? 'Job';
            return WriteReviewScreen(jobId: jobId, workerId: workerId, jobTitle: jobTitle);
          },
        ),

        // Dedicated Customer Sub-routes
        GoRoute(
          path: RouteNames.customerPostJob,
          builder: (context, state) => const PostJobScreen(),
        ),
        GoRoute(
          path: '/customer/workers/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final worker = state.extra as WorkerModel?;
            return WorkerDetailScreen(workerId: id, initialWorker: worker);
          },
        ),
        GoRoute(
          path: '/customer/jobs/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final job = state.extra as JobModel?;
            return JobDetailScreen(jobId: id, initialJob: job);
          },
        ),
        GoRoute(
          path: '/customer/jobs/:id/applications',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final job = state.extra as JobModel?;
            return JobApplicationsScreen(jobId: id, initialJob: job);
          },
        ),

        // Customer Shell Route
        ShellRoute(
          builder: (context, state, child) => CustomerShellScreen(child: child),
          routes: [
            GoRoute(
              path: RouteNames.customerDashboard,
              builder: (context, state) => const CustomerDashboardScreen(),
            ),
            GoRoute(
              path: RouteNames.customerFindWorkers,
              builder: (context, state) => const FindWorkersScreen(),
            ),
            GoRoute(
              path: RouteNames.customerJobs,
              builder: (context, state) => const CustomerJobsScreen(),
            ),
            GoRoute(
              path: RouteNames.customerSavedWorkers,
              builder: (context, state) => const SavedWorkersScreen(),
            ),
          ],
        ),

        // Dedicated Worker Sub-routes
        GoRoute(
          path: '/worker/jobs/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final job = state.extra as JobModel?;
            return JobDetailScreen(jobId: id, initialJob: job);
          },
        ),
        GoRoute(
          path: '/worker/apply-job/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final job = state.extra as JobModel?;
            return ApplyJobScreen(jobId: id, initialJob: job);
          },
        ),
        GoRoute(
          path: RouteNames.workerEditProfile,
          builder: (context, state) => const EditWorkerProfileScreen(),
        ),

        // Worker Shell Route
        ShellRoute(
          builder: (context, state, child) => WorkerShellScreen(child: child),
          routes: [
            GoRoute(
              path: RouteNames.workerDashboard,
              builder: (context, state) => const WorkerDashboardScreen(),
            ),
            GoRoute(
              path: RouteNames.workerBrowseJobs,
              builder: (context, state) => const BrowseJobsScreen(),
            ),
            GoRoute(
              path: RouteNames.workerApplications,
              builder: (context, state) => const MyApplicationsScreen(),
            ),
            GoRoute(
              path: RouteNames.workerProfile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
