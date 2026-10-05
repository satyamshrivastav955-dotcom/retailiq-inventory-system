import 'package:flutter_test/flutter_test.dart';
import 'package:k11_project/utils/helpers.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty email', () {
      expect(validateEmail(null), isNotNull);
      expect(validateEmail(''), isNotNull);
    });

    test('rejects invalid email', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('user@'), isNotNull);
    });

    test('accepts valid email', () {
      expect(validateEmail('owner@store.com'), isNull);
    });
  });

  group('validatePositiveNumber', () {
    test('rejects empty and negative', () {
      expect(validatePositiveNumber(null, 'Cost price'), isNotNull);
      expect(validatePositiveNumber('', 'Cost price'), isNotNull);
      expect(validatePositiveNumber('-5', 'Cost price'), isNotNull);
      expect(validatePositiveNumber('abc', 'Cost price'), isNotNull);
    });

    test('accepts zero and positive decimals', () {
      expect(validatePositiveNumber('0', 'Cost price'), isNull);
      expect(validatePositiveNumber('12.50', 'Cost price'), isNull);
    });
  });

  group('validateNonNegativeInt', () {
    test('rejects decimals and garbage', () {
      expect(validateNonNegativeInt('12.5', 'Quantity'), isNotNull);
      expect(validateNonNegativeInt('abc', 'Quantity'), isNotNull);
      expect(validateNonNegativeInt('-1', 'Quantity'), isNotNull);
      expect(validateNonNegativeInt('', 'Quantity'), isNotNull);
    });

    test('accepts whole numbers', () {
      expect(validateNonNegativeInt('0', 'Quantity'), isNull);
      expect(validateNonNegativeInt('5', 'Quantity'), isNull);
    });
  });

  group('expiry helpers', () {
    test('isExpired handles null and past dates', () {
      expect(isExpired(null), isFalse);
      expect(
        isExpired(DateTime.now().subtract(const Duration(days: 1))),
        isTrue,
      );
      expect(
        isExpired(DateTime.now().add(const Duration(days: 1))),
        isFalse,
      );
    });

    test('isExpiringSoon detects 7-day window', () {
      expect(isExpiringSoon(null), isFalse);
      expect(
        isExpiringSoon(DateTime.now().add(const Duration(days: 3))),
        isTrue,
      );
      expect(
        isExpiringSoon(DateTime.now().add(const Duration(days: 30))),
        isFalse,
      );
    });
  });
}
