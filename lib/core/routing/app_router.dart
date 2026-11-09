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
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RouteNames.landing,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        final isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.currentUser;
        final location = state.uri.toString();

        if (status == AuthStatus.loading || status == AuthStatus.uninitialized) {
          return null; // Don't redirect while auth is still loading
        }

        // Public allowed routes
        final isAuthRoute = location == RouteNames.login ||
            location == RouteNames.register ||
            location == RouteNames.forgotPassword;
        final isPublicAllowed = location == RouteNames.landing ||
            location.startsWith('/customer/find-workers') ||
            location.startsWith('/customer/workers/');

        // If in recoverable error state (network error, missing profile, suspended)
        if (status == AuthStatus.networkError ||
            status == AuthStatus.profileMissing ||
            status == AuthStatus.accountSuspended) {
          if (location == RouteNames.authError) return null;
          if (isPublicAllowed || isAuthRoute) return null;
          return RouteNames.authError;
        }

        // If not authenticated and attempting to view protected route
        if (!isAuthenticated) {
          if (isAuthRoute || isPublicAllowed) return null;
          return RouteNames.login;
        }

        // If authenticated and visiting auth routes (login/register)
        if (isAuthRoute) {
          return authProvider.determineInitialRoute();
        }

        // Protected role enforcement
        if (user != null) {
          // If accessing customer private routes, user must have customer role
          if (location.startsWith('/customer/') &&
              !location.startsWith('/customer/find-workers') &&
              !location.startsWith('/customer/workers/') &&
              !user.isCustomer) {
            return authProvider.determineInitialRoute();
          }

          // If accessing worker routes, user must have worker role
          if (location.startsWith('/worker/') && !user.isWorker) {
            return authProvider.determineInitialRoute();
          }

          // If worker profile incomplete, redirect to onboarding
          if (user.isWorkerActive &&
              !authProvider.isWorkerOnboarded &&
              location.startsWith('/worker/') &&
              location != RouteNames.workerOnboarding) {
            return RouteNames.workerOnboarding;
          }
        }

        return null;
      },
      routes: [
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
