import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../providers/auth_provider.dart';

class CustomerShellScreen extends StatefulWidget {
  final Widget child;

  const CustomerShellScreen({super.key, required this.child});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.customerDashboard)) return 0;
    if (location.startsWith(RouteNames.customerFindWorkers)) return 1;
    if (location.startsWith(RouteNames.customerJobs) || location.startsWith(RouteNames.customerPostJob)) return 2;
    if (location.startsWith(RouteNames.customerSavedWorkers)) return 3;
    if (location.startsWith(RouteNames.profile) || location.startsWith(RouteNames.settings)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.customerDashboard);
        break;
      case 1:
        context.go(RouteNames.customerFindWorkers);
        break;
      case 2:
        context.go(RouteNames.customerJobs);
        break;
      case 3:
        context.go(RouteNames.customerSavedWorkers);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }

  Future<void> _handleSwitchToWorker(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    if (!user.roles.contains(AppConstants.roleWorker)) {
      context.push(RouteNames.roleEnroll, extra: AppConstants.roleWorker);
      return;
    }

    final res = await authProvider.switchPortal(AppConstants.roleWorker);
    if (!context.mounted) return;

    if (res == 'success') {
      context.go(RouteNames.workerDashboard);
    } else if (res == 'needs_worker_onboarding') {
      context.go(RouteNames.workerOnboarding);
    } else {
      CustomSnackBar.showError(context, 'Unable to switch to worker portal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: InkWell(
          onTap: () => context.go(RouteNames.customerDashboard),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.handshake_rounded, color: AppColors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.appName,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.deepForestTeal),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tealSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Customer',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Switch to Worker Action Pill
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGrey),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.terracotta),
            label: Text(
              user?.roles.contains(AppConstants.roleWorker) == true ? 'Worker Portal' : 'Become a Worker',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal),
            ),
            onPressed: () => _handleSwitchToWorker(context),
          ),
          const SizedBox(width: 8),
          // Notifications Icon
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.charcoal),
            onPressed: () => context.push(RouteNames.notifications),
          ),
          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: InkWell(
              onTap: () => context.go(RouteNames.profile),
              borderRadius: BorderRadius.circular(20),
              child: AppAvatar(
                name: user?.fullName ?? 'User',
                imageUrl: user?.photoUrl,
                radius: 18,
              ),
            ),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (idx) => _onItemTapped(idx, context),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.white,
                  selectedIconTheme: const IconThemeData(color: AppColors.primaryTeal),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.secondaryGrey,
                    fontSize: 12,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      selectedIcon: Icon(Icons.saved_search_rounded),
                      label: Text('Find Workers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.work_outline_rounded),
                      selectedIcon: Icon(Icons.work_rounded),
                      label: Text('My Jobs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_border_rounded),
                      selectedIcon: Icon(Icons.bookmark_rounded),
                      label: Text('Saved'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1, color: AppColors.borderGrey),
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              backgroundColor: AppColors.white,
              indicatorColor: AppColors.tealSurface,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryTeal),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded, color: AppColors.primaryTeal),
                  label: 'Find Workers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(Icons.work_rounded, color: AppColors.primaryTeal),
                  label: 'My Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primaryTeal),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryTeal),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

