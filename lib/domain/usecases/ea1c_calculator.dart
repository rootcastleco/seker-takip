import 'dart:math';
import '../../core/constants.dart';
import '../entities/glucose_record.dart';

/// Tahmini HbA1c hesaplayıcısı.
///
/// Formül: eA1c = (Ortalama Glukoz mg/dL + 46.7) / 28.7
/// Kaynak: Nathan DM et al., Diabetes Care 2008.
///
/// Minimum [kEa1cMinRecords] kayıt, son [kEa1cDayRange] gün aralığında.
class Ea1cResult {
  const Ea1cResult({
    required this.ea1c,
    required this.averageGlucose,
    required this.recordCount,
    required this.measurementCount,
  });

  /// Tahmini A1c yüzde değeri (ör: 6.5).
  final double ea1c;

  /// Ortalama glukoz mg/dL.
  final double averageGlucose;

  /// Hesaplamaya dahil edilen kayıt sayısı.
  final int recordCount;

  /// Hesaplamaya dahil edilen ölçüm sayısı.
  final int measurementCount;

  String get formattedEa1c => ea1c.toStringAsFixed(1);
  String get formattedAvg => averageGlucose.toStringAsFixed(0);
}

/// Glukoz değişkenlik (variabilite) sonucu.
class GlucoseVariabilityResult {
  const GlucoseVariabilityResult({
    required this.standardDeviation,
    required this.mean,
    required this.coefficientOfVariation,
    required this.measurementCount,
  });

  /// Standart sapma mg/dL.
  final double standardDeviation;

  /// Ortalama mg/dL.
  final double mean;

  /// Varyasyon katsayısı (CV%) = SD / Ortalama * 100.
  final double coefficientOfVariation;

  /// Ölçüm sayısı.
  final int measurementCount;

  /// Stabilite seviyesi.
  /// SD < 20: Stabil (Yeşil Kalkan).
  /// SD 20-40: Orta.
  /// SD > 40: Yüksek (Kırmızı Uyarı + Voice alert).
  StabilityLevel get level {
    if (standardDeviation < 20) return StabilityLevel.stable;
    if (standardDeviation <= 40) return StabilityLevel.moderate;
    return StabilityLevel.high;
  }

  String get formattedSD => standardDeviation.toStringAsFixed(1);
  String get formattedCV => coefficientOfVariation.toStringAsFixed(1);
}

enum StabilityLevel { stable, moderate, high }

class Ea1cCalculator {
  Ea1cCalculator._();

  /// Son [kEa1cDayRange] günlük kayıtlardan eA1c hesaplar.
  /// Kayıt yetersizse `null` döner.
  static Ea1cResult? calculate(List<GlucoseRecordEntity> records) {
    if (records.length < kEa1cMinRecords) return null;

    final allValues = records
        .expand((r) => r.allMeasurements)
        .whereType<int>()
        .toList();

    if (allValues.isEmpty) return null;

    final sum = allValues.fold<int>(0, (a, b) => a + b);
    final avg = sum / allValues.length;
    final ea1c = (avg + 46.7) / 28.7;

    return Ea1cResult(
      ea1c: ea1c,
      averageGlucose: avg,
      recordCount: records.length,
      measurementCount: allValues.length,
    );
  }

  /// Glukoz değişkenlik (SD) hesaplar.
  /// Yetersizse `null` döner.
  static GlucoseVariabilityResult? calculateVariability(
    List<GlucoseRecordEntity> records,
  ) {
    final allValues = records
        .expand((r) => r.allMeasurements)
        .whereType<int>()
        .toList();

    if (allValues.length < 3) return null;

    final n = allValues.length;
    final sum = allValues.fold<int>(0, (a, b) => a + b);
    final mean = sum / n;

    // Standart sapma (population SD)
    final varianceSum = allValues.fold<double>(
      0,
      (acc, v) => acc + (v - mean) * (v - mean),
    );
    final sd = sqrt(varianceSum / n);

    final cv = mean > 0 ? (sd / mean) * 100 : 0.0;

    return GlucoseVariabilityResult(
      standardDeviation: sd,
      mean: mean,
      coefficientOfVariation: cv,
      measurementCount: n,
    );
  }
}
