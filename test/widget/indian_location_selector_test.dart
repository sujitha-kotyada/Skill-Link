import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/widgets/indian_location_selector.dart';

void main() {
  Widget buildTestWidget({
    String? initialState,
    String? initialCity,
    ValueChanged<String?>? onStateChanged,
    ValueChanged<String?>? onCityChanged,
    GlobalKey<FormState>? formKey,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: IndianLocationSelector(
            initialSelectedState: initialState,
            initialSelectedCity: initialCity,
            onStateChanged: onStateChanged ?? (_) {},
            onCityChanged: onCityChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('IndianLocationSelector Widget Tests', () {
    testWidgets('Renders State and City dropdowns, City disabled initially when no state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('State / Union Territory'), findsOneWidget);
      expect(find.text('City / Town'), findsOneWidget);
      expect(find.text('Select State / UT'), findsOneWidget);
      expect(find.text('Select State first'), findsOneWidget);
    });

    testWidgets('City dropdown is enabled and populated when state is provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        initialState: 'Karnataka',
        initialCity: 'Bengaluru',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Karnataka'), findsOneWidget);
      expect(find.text('Bengaluru'), findsOneWidget);
    });

    testWidgets('Validation shows errors when fields are empty', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildTestWidget(formKey: formKey));
      await tester.pumpAndSettle();

      final isValid = formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(isValid, isFalse);
      expect(find.text('Please select a state'), findsOneWidget);
    });
  });
}
