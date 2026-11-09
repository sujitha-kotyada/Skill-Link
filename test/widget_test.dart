import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_strings.dart';
import 'package:skill_link/core/theme/app_theme.dart';
import 'package:skill_link/features/landing/widgets/hero_section.dart';

void main() {
  testWidgets('Skill-Link brand and hero layout smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: HeroSection(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify brand headlines
    expect(find.text(AppStrings.heroHeadline), findsOneWidget);
    expect(find.text(AppStrings.findSkilledWorkers), findsOneWidget);
    expect(find.text(AppStrings.offerYourSkills), findsOneWidget);
    expect(find.text('Verified Local Marketplace'), findsOneWidget);
  });
}
