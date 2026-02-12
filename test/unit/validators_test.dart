import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/core/validators.dart';

void main() {
  group('validateGlucose', () {
    test('null/boş değer geçerlidir (nullable alan)', () {
      expect(validateGlucose(null), isNull);
      expect(validateGlucose(''), isNull);
      expect(validateGlucose('  '), isNull);
    });

    test('geçerli değerler (20–600)', () {
      expect(validateGlucose('20'), isNull);
      expect(validateGlucose('100'), isNull);
      expect(validateGlucose('600'), isNull);
    });

    test('geçersiz aralık', () {
      expect(validateGlucose('0'), isNotNull);
      expect(validateGlucose('19'), isNotNull);
      expect(validateGlucose('601'), isNotNull);
      expect(validateGlucose('999'), isNotNull);
    });

    test('sayı olmayan değer', () {
      expect(validateGlucose('abc'), isNotNull);
      expect(validateGlucose('12.5'), isNotNull);
    });
  });

  group('hasAtLeastOneMeasurement', () {
    test('en az bir değer doluysa true', () {
      expect(hasAtLeastOneMeasurement([null, 100, null]), isTrue);
      expect(hasAtLeastOneMeasurement([50]), isTrue);
    });

    test('tümü null ise false', () {
      expect(hasAtLeastOneMeasurement([null, null, null]), isFalse);
      expect(hasAtLeastOneMeasurement([]), isFalse);
    });
  });

  group('isFutureDate', () {
    test('bugün gelecek değildir', () {
      expect(isFutureDate(DateTime.now()), isFalse);
    });

    test('dün gelecek değildir', () {
      expect(
        isFutureDate(DateTime.now().subtract(const Duration(days: 1))),
        isFalse,
      );
    });

    test('yarın gelecektir', () {
      expect(isFutureDate(DateTime.now().add(const Duration(days: 1))), isTrue);
    });
  });

  group('validateAge', () {
    test('geçerli yaşlar', () {
      expect(validateAge('1'), isNull);
      expect(validateAge('75'), isNull);
      expect(validateAge('150'), isNull);
    });

    test('geçersiz yaşlar', () {
      expect(validateAge('0'), isNotNull);
      expect(validateAge('151'), isNotNull);
      expect(validateAge('abc'), isNotNull);
    });

    test('boş bırakılabilir', () {
      expect(validateAge(''), isNull);
      expect(validateAge(null), isNull);
    });
  });

  group('validateWeight', () {
    test('geçerli kilo', () {
      expect(validateWeight('50'), isNull);
      expect(validateWeight('120.5'), isNull);
    });

    test('geçersiz kilo', () {
      expect(validateWeight('0'), isNotNull);
      expect(validateWeight('501'), isNotNull);
    });
  });
}
