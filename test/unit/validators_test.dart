import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/utils/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('validateEmail correctly accepts valid emails', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('ramesh.kumar@domain.in'), isNull);
      expect(Validators.validateEmail('worker_123@skilllink.org'), isNull);
    });

    test('validateEmail rejects empty and invalid formats', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('not-an-email'), isNotNull);
      expect(Validators.validateEmail('missing@domain'), isNotNull);
      expect(Validators.validateEmail('@nodomain.com'), isNotNull);
    });

    test('validatePassword validates minimum length requirement', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('StrongPass#2026'), isNull);
    });

    test('validateConfirmPassword checks equality', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
      expect(Validators.validateConfirmPassword('pass123', 'different'), isNotNull);
      expect(Validators.validateConfirmPassword('', 'pass123'), isNotNull);
    });

    test('validateNumber enforces positive numerics', () {
      expect(Validators.validateNumber('500'), isNull);
      expect(Validators.validateNumber('0'), isNull);
      expect(Validators.validateNumber('1250.50'), isNull);
      expect(Validators.validateNumber('-100'), isNotNull);
      expect(Validators.validateNumber('abc'), isNotNull);
      expect(Validators.validateNumber(''), isNotNull);
    });

    test('validatePhone validates 10-digit Indian numbers', () {
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('+91 98765-43210'), isNull);
      expect(Validators.validatePhone('12345'), isNotNull);
      expect(Validators.validatePhone(null), isNull); // Optional
    });
  });
}
