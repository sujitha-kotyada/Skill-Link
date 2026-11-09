import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class SkillLinkApp extends StatefulWidget {
  const SkillLinkApp({super.key});

  @override
  State<SkillLinkApp> createState() => _SkillLinkAppState();
}

class _SkillLinkAppState extends State<SkillLinkApp> {
  late final AuthProvider _authProvider;
  late final CustomerProvider _customerProvider;
  late final WorkerProvider _workerProvider;
  late final JobProvider _jobProvider;
  late final ApplicationProvider _applicationProvider;
  late final NotificationProvider _notificationProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _customerProvider = CustomerProvider();
    _workerProvider = WorkerProvider();
    _jobProvider = JobProvider();
    _applicationProvider = ApplicationProvider();
    _notificationProvider = NotificationProvider();
    // Instantiate GoRouter ONCE with refreshListenable pointing to the AuthProvider
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _customerProvider.dispose();
    _workerProvider.dispose();
    _jobProvider.dispose();
    _applicationProvider.dispose();
    _notificationProvider.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<CustomerProvider>.value(value: _customerProvider),
        ChangeNotifierProvider<WorkerProvider>.value(value: _workerProvider),
        ChangeNotifierProvider<JobProvider>.value(value: _jobProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: _applicationProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: _notificationProvider),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
