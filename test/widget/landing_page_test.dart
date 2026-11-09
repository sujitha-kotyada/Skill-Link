import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_link/core/constants/app_strings.dart';
import 'package:skill_link/features/landing/screens/landing_page.dart';
import 'package:skill_link/providers/customer_provider.dart';

void main() {
  testWidgets('LandingPage renders hero, branding, headlines and category sections',
      (WidgetTester tester) async {
    // Set a large screen size to test full desktop layout
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CustomerProvider>(
            create: (_) => CustomerProvider(),
          ),
        ],
        child: const MaterialApp(
          home: LandingPage(),
        ),
      ),
    );
    await tester.pump();

    // Verify brand name & hero text
    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.heroHeadline), findsOneWidget);
    expect(find.text(AppStrings.findSkilledWorkers), findsOneWidget);
    expect(find.text(AppStrings.offerYourSkills), findsOneWidget);

    // Verify categories & how it works
    expect(find.text('POPULAR SERVICE CATEGORIES'), findsOneWidget);
    expect(find.text('Electrician'), findsWidgets);
    expect(find.text('Plumber'), findsWidgets);
    expect(find.text('Carpenter'), findsWidgets);

    // Verify 'What is Skill-Link?' section is present
    expect(find.text('What is Skill-Link?'), findsOneWidget);

    // Verify Top Rated Workers section is completely removed from LandingPage
    expect(find.text('TOP RATED LOCAL TALENT'), findsNothing);
    expect(find.text('Explore Skilled Professionals'), findsNothing);
    expect(find.text('Sunil Sharma'), findsNothing);
  });
}

