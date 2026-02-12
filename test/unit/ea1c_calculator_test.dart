import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/domain/usecases/ea1c_calculator.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  GlucoseRecordEntity _makeRecord({
    int? sabahAc,
    int? sabahTok,
    int? oglenAc,
    int? oglenTok,
    int? aksamAc,
    int? aksamTok,
    int? yatmadanOnce,
    int? gece03,
    DateTime? tarih,
  }) {
    final now = tarih ?? DateTime.now();
    return GlucoseRecordEntity(
      id: 0,
      tarih: now,
      sabahAc: sabahAc,
      sabahTok: sabahTok,
      oglenAc: oglenAc,
      oglenTok: oglenTok,
      aksamAc: aksamAc,
      aksamTok: aksamTok,
      yatmadanOnce: yatmadanOnce,
      gece03: gece03,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Ea1cCalculator.calculate', () {
    test('yetersiz kayıt → null', () {
      final result = Ea1cCalculator.calculate([]);
      expect(result, isNull);
    });

    test('tekrar eden 100 mg/dL → eA1c ≈ 5.1', () {
      // eA1c = (100 + 46.7) / 28.7 ≈ 5.112
      final records = List.generate(
        20,
        (i) => _makeRecord(
          sabahAc: 100,
          tarih: DateTime.now().subtract(Duration(days: i)),
        ),
      );
      final result = Ea1cCalculator.calculate(records);
      expect(result, isNotNull);
      expect(result!.ea1c, closeTo(5.1, 0.1));
      expect(result.averageGlucose, closeTo(100, 1));
    });

    test('yüksek değerler → yüksek eA1c', () {
      final records = List.generate(
        20,
        (i) => _makeRecord(
          sabahAc: 250,
          tarih: DateTime.now().subtract(Duration(days: i)),
        ),
      );
      final result = Ea1cCalculator.calculate(records);
      expect(result, isNotNull);
      // eA1c = (250 + 46.7) / 28.7 ≈ 10.34
      expect(result!.ea1c, greaterThan(10));
    });
  });

  group('Ea1cCalculator.calculateVariability (SD eşikleri)', () {
    test('sabit değerler → düşük SD (< 20)', () {
      final records = List.generate(
        20,
        (i) => _makeRecord(
          sabahAc: 100,
          tarih: DateTime.now().subtract(Duration(days: i)),
        ),
      );
      final result = Ea1cCalculator.calculateVariability(records);
      expect(result, isNotNull);
      // Tüm değerler aynı → SD = 0
      expect(result!.standardDeviation, lessThan(20));
    });

    test('çok değişken değerler → yüksek SD (> 40)', () {
      // 50 ve 250 arası zıplayan değerler
      final records = List.generate(
        20,
        (i) => _makeRecord(
          sabahAc: i.isEven ? 50 : 250,
          tarih: DateTime.now().subtract(Duration(days: i)),
        ),
      );
      final result = Ea1cCalculator.calculateVariability(records);
      expect(result, isNotNull);
      expect(result!.standardDeviation, greaterThan(40));
    });

    test('yetersiz kayıt → null', () {
      final result = Ea1cCalculator.calculateVariability([]);
      expect(result, isNull);
    });
  });
}
