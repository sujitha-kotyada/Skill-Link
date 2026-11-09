import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/indian_locations.dart';

void main() {
  group('IndianLocations Dataset & Logic Tests', () {
    test('Dataset contains all 28 Indian States and 8 Union Territories (36 total)', () {
      expect(IndianLocations.indianStates.length, 28);
      expect(IndianLocations.unionTerritories.length, 8);
      expect(IndianLocations.statesAndUTs.length, 36);

      // Verify states are sorted alphabetically
      final stateNames = List<String>.from(IndianLocations.indianStates);
      final sortedStates = List<String>.from(stateNames)..sort();
      expect(stateNames, sortedStates);

      // Verify UTs are sorted alphabetically
      final utNames = List<String>.from(IndianLocations.unionTerritories);
      final sortedUTs = List<String>.from(utNames)..sort();
      expect(utNames, sortedUTs);
    });

    test('Major states have extensive major cities mapped', () {
      // Karnataka
      final karnatakaCities = IndianLocations.getCitiesForState('Karnataka');
      expect(karnatakaCities, contains('Bengaluru'));
      expect(karnatakaCities, contains('Mysuru'));
      expect(karnatakaCities, contains('Hubballi-Dharwad'));
      expect(karnatakaCities, contains('Mangaluru'));

      // Maharashtra
      final maharashtraCities = IndianLocations.getCitiesForState('Maharashtra');
      expect(maharashtraCities, contains('Mumbai'));
      expect(maharashtraCities, contains('Pune'));
      expect(maharashtraCities, contains('Nagpur'));
      expect(maharashtraCities, contains('Nashik'));

      // Delhi
      final delhiCities = IndianLocations.getCitiesForState('Delhi');
      expect(delhiCities, contains('New Delhi'));
      expect(delhiCities, contains('North Delhi'));

      // Tamil Nadu
      final tnCities = IndianLocations.getCitiesForState('Tamil Nadu');
      expect(tnCities, contains('Chennai'));
      expect(tnCities, contains('Coimbatore'));
    });

    test('getCitiesForState returns empty list for invalid or null state', () {
      expect(IndianLocations.getCitiesForState(null), isEmpty);
      expect(IndianLocations.getCitiesForState(''), isEmpty);
      expect(IndianLocations.getCitiesForState('NonExistentState'), isEmpty);
    });

    test('isValidState and isValidCity checks', () {
      expect(IndianLocations.isValidState('Karnataka'), isTrue);
      expect(IndianLocations.isValidState('Delhi'), isTrue);
      expect(IndianLocations.isValidState('California'), isFalse);
      expect(IndianLocations.isValidState(''), isFalse);

      expect(IndianLocations.isValidCity('Karnataka', 'Bengaluru'), isTrue);
      expect(IndianLocations.isValidCity('Karnataka', 'Mumbai'), isFalse);
      expect(IndianLocations.isValidCity('Maharashtra', 'Mumbai'), isTrue);
      expect(IndianLocations.isValidCity('InvalidState', 'Bengaluru'), isFalse);
    });

    test('getAvailableStates preserves custom or legacy state without duplication', () {
      final defaultList = IndianLocations.getAvailableStates();
      expect(defaultList.length, 36);

      // Existing standard state does not duplicate
      final listWithStandard = IndianLocations.getAvailableStates('Karnataka');
      expect(listWithStandard.length, 36);

      // Legacy or custom state is prepended
      final listWithCustom = IndianLocations.getAvailableStates('Custom Legacy Region');
      expect(listWithCustom.length, 37);
      expect(listWithCustom.first, 'Custom Legacy Region');
    });

    test('getAvailableCities preserves custom or legacy city without duplication', () {
      final standardCities = IndianLocations.getAvailableCities('Karnataka');
      expect(standardCities, contains('Bengaluru'));

      // Existing standard city does not duplicate
      final withStandard = IndianLocations.getAvailableCities('Karnataka', 'Bengaluru');
      expect(withStandard.where((c) => c == 'Bengaluru').length, 1);

      // Legacy custom city in Karnataka is preserved and prepended
      final withCustom = IndianLocations.getAvailableCities('Karnataka', 'Custom Town');
      expect(withCustom.first, 'Custom Town');
      expect(withCustom, contains('Bengaluru'));
    });
  });
}
