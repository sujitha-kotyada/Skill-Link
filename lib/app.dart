import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/job_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/worker_provider.dart';

class SkillLinkApp extends StatelessWidget {
  const SkillLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (_) => CustomerProvider(),
        ),
        ChangeNotifierProvider<WorkerProvider>(
          create: (_) => WorkerProvider(),
        ),
        ChangeNotifierProvider<JobProvider>(
          create: (_) => JobProvider(),
        ),
        ChangeNotifierProvider<ApplicationProvider>(
          create: (_) => ApplicationProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final router = AppRouter.createRouter(authProvider);

          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
