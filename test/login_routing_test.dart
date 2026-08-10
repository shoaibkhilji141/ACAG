import 'package:acag/shared/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants.resolveDemoRole', () {
    test('routes engineer email to engineer', () {
      expect(
        AppConstants.resolveDemoRole(
          'shoaibkhilji141@gmail.com',
          '12345678',
        ),
        UserRole.engineer,
      );
      expect(
        AppConstants.routeForRole(UserRole.engineer),
        AppRoutes.engineerShell,
      );
    });

    test('routes owner email to owner', () {
      expect(
        AppConstants.resolveDemoRole(
          'ali.raza.owner@gmail.com',
          '12345678',
        ),
        UserRole.owner,
      );
      expect(
        AppConstants.routeForRole(UserRole.owner),
        AppRoutes.ownerShell,
      );
    });

    test('is case-insensitive for email', () {
      expect(
        AppConstants.resolveDemoRole(
          'ShoaibKhilji141@Gmail.com',
          '12345678',
        ),
        UserRole.engineer,
      );
    });

    test('rejects wrong password', () {
      expect(
        AppConstants.resolveDemoRole(
          'shoaibkhilji141@gmail.com',
          'wrong',
        ),
        isNull,
      );
    });

    test('rejects unknown email', () {
      expect(
        AppConstants.resolveDemoRole('other@gmail.com', '12345678'),
        isNull,
      );
    });
  });
}
