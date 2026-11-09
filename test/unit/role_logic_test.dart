import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/models/user_model.dart';

void main() {
  group('Role Logic & Escalation Security Unit Tests', () {
    test('Valid roles are strictly restricted to customer and worker', () {
      expect(AppConstants.validRoles, contains(AppConstants.roleCustomer));
      expect(AppConstants.validRoles, contains(AppConstants.roleWorker));
      expect(AppConstants.validRoles.length, 2);
      expect(AppConstants.validRoles.contains('admin'), isFalse);
      expect(AppConstants.validRoles.contains('superadmin'), isFalse);
    });

    test('Single-role user cannot switch to unenrolled role', () {
      final customerOnly = UserModel(
        uid: 'user_1',
        fullName: 'Customer Only',
        email: 'customer@test.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customerOnly.canSwitchTo(AppConstants.roleCustomer), isTrue);
      expect(customerOnly.canSwitchTo(AppConstants.roleWorker), isFalse);
      expect(customerOnly.isWorker, isFalse);
      expect(customerOnly.hasBothRoles, isFalse);
    });

    test('Enrolling in a second role preserves existing role membership', () {
      final initialCustomer = UserModel(
        uid: 'user_2',
        fullName: 'Dual User',
        email: 'dual@test.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add Worker role
      final updatedRoles = List<String>.from(initialCustomer.roles)..add(AppConstants.roleWorker);
      final dualRoleUser = initialCustomer.copyWith(
        roles: updatedRoles,
        activeRole: AppConstants.roleWorker,
      );

      expect(dualRoleUser.roles, contains(AppConstants.roleCustomer));
      expect(dualRoleUser.roles, contains(AppConstants.roleWorker));
      expect(dualRoleUser.hasBothRoles, isTrue);
      expect(dualRoleUser.canSwitchTo(AppConstants.roleCustomer), isTrue);
      expect(dualRoleUser.canSwitchTo(AppConstants.roleWorker), isTrue);
      expect(dualRoleUser.activeRole, AppConstants.roleWorker);
    });

    test('activeRole is purely an interface preference and does not modify permissions', () {
      final dualUser = UserModel(
        uid: 'user_3',
        fullName: 'Switch User',
        email: 'switch@test.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dualUser.isCustomerActive, isTrue);
      expect(dualUser.isWorkerActive, isFalse);
      // But actual capabilities still exist!
      expect(dualUser.isWorker, isTrue);

      final switched = dualUser.copyWith(activeRole: AppConstants.roleWorker);
      expect(switched.isWorkerActive, isTrue);
      expect(switched.isCustomerActive, isFalse);
      expect(switched.isCustomer, isTrue);
    });
  });
}
