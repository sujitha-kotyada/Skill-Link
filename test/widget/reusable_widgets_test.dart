import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/core/widgets/app_button.dart';
import 'package:skill_link/core/widgets/empty_state_view.dart';
import 'package:skill_link/core/widgets/rating_stars.dart';
import 'package:skill_link/core/widgets/role_badge.dart';
import 'package:skill_link/core/widgets/status_badge.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('Reusable Core Widgets Tests', () {
    testWidgets('AppButton renders label and handles clicks', (tester) async {
      bool clicked = false;
      await tester.pumpWidget(wrapWidget(
        AppButton(
          label: 'Submit Job',
          onPressed: () => clicked = true,
          variant: AppButtonVariant.primary,
        ),
      ));

      expect(find.text('Submit Job'), findsOneWidget);
      await tester.tap(find.text('Submit Job'));
      expect(clicked, isTrue);
    });

    testWidgets('AppButton shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppButton(
          label: 'Save',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('StatusBadge displays correct text for each state', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const Column(
          children: [
            StatusBadge(status: 'open'),
            StatusBadge(status: 'applied'),
            StatusBadge(status: 'accepted'),
            StatusBadge(status: 'rejected'),
          ],
        ),
      ));

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Applied'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('RoleBadge renders Customer and Worker badges', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const Row(
          children: [
            RoleBadge(role: AppConstants.roleCustomer),
            RoleBadge(role: AppConstants.roleWorker, isSelected: true),
          ],
        ),
      ));

      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Worker'), findsOneWidget);
    });

    testWidgets('RatingStars displays formatted rating and review count', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const RatingStars(rating: 4.85, reviewCount: 42),
      ));

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(42)'), findsOneWidget);
    });

    testWidgets('EmptyStateView renders title, description, and action button', (tester) async {
      bool buttonTapped = false;
      await tester.pumpWidget(wrapWidget(
        EmptyStateView(
          icon: Icons.work_off_rounded,
          title: 'No Jobs Posted',
          description: 'You have not created any service posts yet.',
          buttonLabel: 'Post Your First Job',
          onButtonPressed: () => buttonTapped = true,
        ),
      ));

      expect(find.text('No Jobs Posted'), findsOneWidget);
      expect(find.text('You have not created any service posts yet.'), findsOneWidget);
      expect(find.text('Post Your First Job'), findsOneWidget);

      await tester.tap(find.text('Post Your First Job'));
      expect(buttonTapped, isTrue);
    });
  });
}

