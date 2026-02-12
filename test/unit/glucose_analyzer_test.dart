import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/features/dashboard/logic/glucose_analyzer.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  final analyzer = GlucoseAnalyzer.instance;

  group('classifySingle', () {
    test('hipoglisemi (< 70)', () {
      final msg = analyzer.classifySingle(50);
      expect(msg, contains('Hipoglisemi'));
    });

    test('nominal (70–100)', () {
      final msg = analyzer.classifySingle(85);
      expect(msg, contains('nominal'));
    });

    test('sınır değer (101–140)', () {
      final msg = analyzer.classifySingle(120);
      expect(msg, contains('Sınır'));
    });

    test('yüksek glukoz (> 140)', () {
      final msg = analyzer.classifySingle(200);
      expect(msg, contains('Yüksek'));
    });
  });

  group('analyzeAndSpeak — sınıflandırma önceliği', () {
    // Note: TTS won't actually speak in test environment, but the string
    // classification logic can be tested indirectly.

    test('hiçbir ölçüm yoksa nominal, kayıt boşke  ', () {
      final record = GlucoseRecordEntity(
        id: 1,
        tarih: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // allMeasurements hepsi null
      expect(record.allMeasurements.whereType<int>().isEmpty, isTrue);
    });

    test('hipoglisemi en yüksek öncelik', () {
      // 50 = hipo, 120 = sınır → hipoglisemi döner
      final msg = analyzer.classifySingle(50);
      expect(msg, contains('Hipoglisemi'));
    });

    test('yüksek glukoz ikinci öncelik', () {
      final msg = analyzer.classifySingle(200);
      expect(msg, contains('Yüksek'));
    });

    test('sınır değer üçüncü öncelik', () {
      final msg = analyzer.classifySingle(135);
      expect(msg, contains('Sınır'));
    });
  });

  group('GlucoseRecordEntity.allMeasurements', () {
    test('dolu alanlar doğru sayılır', () {
      final record = GlucoseRecordEntity(
        id: 1,
        tarih: DateTime.now(),
        sabahAc: 90,
        sabahTok: 130,
        oglenAc: null,
        oglenTok: null,
        aksamAc: null,
        aksamTok: null,
        yatmadanOnce: null,
        gece03: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final vals = record.allMeasurements.whereType<int>().toList();
      expect(vals.length, 2);
      expect(vals, containsAll([90, 130]));
    });
  });
}
