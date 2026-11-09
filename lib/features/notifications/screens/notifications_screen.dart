import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../models/notification_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _handleNotificationTap(BuildContext context, NotificationModel notif) async {
    final notifProvider = context.read<NotificationProvider>();
    final appProvider = context.read<ApplicationProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (!notif.read) {
      await notifProvider.markAsRead(notif.id);
    }

    if (!context.mounted) return;

    if (notif.type == 'application') {
      if (user != null && user.isCustomer) {
        if (notif.relatedId != null && notif.relatedId!.isNotEmpty) {
          try {
            final app = await appProvider.getApplicationById(notif.relatedId!);
            if (context.mounted && app != null) {
              context.push('/customer/jobs/${app.jobId}/applications');
              return;
            }
          } catch (_) {}
        }
        if (context.mounted) {
          context.go(RouteNames.customerJobs);
        }
      } else if (user != null && user.isWorker) {
        context.go(RouteNames.workerApplications);
      }
    } else if (notif.type == 'review') {
      if (user != null && user.isWorker) {
        context.go(RouteNames.workerProfile);
      }
    } else if (notif.type == 'job_status') {
      if (user != null && user.isCustomer) {
        context.go(RouteNames.customerJobs);
      } else if (user != null && user.isWorker) {
        context.go(RouteNames.workerApplications);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in to view notifications.')));
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => notifProvider.markAllAsRead(user.uid),
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 720,
          child: StreamBuilder<List<NotificationModel>>(
            stream: notifProvider.streamNotifications(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return EmptyStateView(
                  icon: Icons.notifications_off_outlined,
                  title: 'No Notifications Yet',
                  description: 'You will receive updates here about job applications, status changes, and reviews.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _NotificationCard(
                    notification: notif,
                    onTap: () => _handleNotificationTap(context, notif),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'application':
        icon = Icons.assignment_ind_rounded;
        iconColor = AppColors.primaryTeal;
        break;
      case 'review':
        icon = Icons.star_rounded;
        iconColor = AppColors.mutedSaffron;
        break;
      case 'job_status':
        icon = Icons.task_alt_rounded;
        iconColor = AppColors.successGreen;
        break;
      default:
        icon = Icons.notifications_active_outlined;
        iconColor = AppColors.infoBlue;
    }

    return AppCard(
      onTap: onTap,
      backgroundColor: notification.read ? AppColors.white : AppColors.tealSurface.withAlpha((0.35 * 255).round()),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.read ? FontWeight.w600 : FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    if (!notification.read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormatter.timeAgo(notification.createdAt),
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryGrey.withAlpha((0.7 * 255).round())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
