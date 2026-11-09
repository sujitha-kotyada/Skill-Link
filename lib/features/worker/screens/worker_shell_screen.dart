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

class WorkerShellScreen extends StatefulWidget {
  final Widget child;

  const WorkerShellScreen({super.key, required this.child});

  @override
  State<WorkerShellScreen> createState() => _WorkerShellScreenState();
}

class _WorkerShellScreenState extends State<WorkerShellScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.workerDashboard)) return 0;
    if (location.startsWith(RouteNames.workerBrowseJobs)) return 1;
    if (location.startsWith(RouteNames.workerApplications)) return 2;
    if (location.startsWith(RouteNames.workerProfile) || location.startsWith(RouteNames.workerEditProfile)) return 3;
    if (location.startsWith(RouteNames.profile) || location.startsWith(RouteNames.settings)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.workerDashboard);
        break;
      case 1:
        context.go(RouteNames.workerBrowseJobs);
        break;
      case 2:
        context.go(RouteNames.workerApplications);
        break;
      case 3:
        context.go(RouteNames.workerProfile);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }

  Future<void> _handleSwitchToCustomer(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    if (!user.roles.contains(AppConstants.roleCustomer)) {
      context.push(RouteNames.roleEnroll, extra: AppConstants.roleCustomer);
      return;
    }

    final res = await authProvider.switchPortal(AppConstants.roleCustomer);
    if (!context.mounted) return;

    if (res == 'success') {
      context.go(RouteNames.customerDashboard);
    } else {
      CustomSnackBar.showError(context, 'Unable to switch to customer portal.');
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
          onTap: () => context.go(RouteNames.workerDashboard),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.handyman_rounded, color: AppColors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.appName,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.charcoal),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE9E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Worker',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.terracotta),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Switch to Customer Action Pill
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGrey),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primaryTeal),
            label: Text(
              user?.roles.contains(AppConstants.roleCustomer) == true ? 'Customer Portal' : 'Hire Workers',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.charcoal),
            ),
            onPressed: () => _handleSwitchToCustomer(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.charcoal),
            onPressed: () => context.push(RouteNames.notifications),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: InkWell(
              onTap: () => context.go(RouteNames.workerProfile),
              borderRadius: BorderRadius.circular(20),
              child: AppAvatar(
                name: user?.fullName ?? 'Worker',
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
                  selectedIconTheme: const IconThemeData(color: AppColors.terracotta),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.terracotta,
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
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded),
                      label: Text('Browse Jobs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment_rounded),
                      label: Text('Applications'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.badge_outlined),
                      selectedIcon: Icon(Icons.badge_rounded),
                      label: Text('My Profile'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Account'),
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
              indicatorColor: const Color(0xFFFBE9E7),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.terracotta),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded, color: AppColors.terracotta),
                  label: 'Browse Jobs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.terracotta),
                  label: 'Applications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge_rounded, color: AppColors.terracotta),
                  label: 'My Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.terracotta),
                  label: 'Account',
                ),
              ],
            ),
    );
  }
}
