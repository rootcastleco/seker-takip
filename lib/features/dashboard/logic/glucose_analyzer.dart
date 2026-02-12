import '../../../core/constants.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/logger/logger.dart';
import '../../../domain/entities/glucose_record.dart';
import '../../../domain/usecases/ea1c_calculator.dart';

/// Glukoz Analiz Motoru — Kayıt sonrası anlık analiz + sesli geri bildirim.
///
/// Iron-Man J.A.R.V.I.S. tarzı, tamamen Türkçe, tıbbi jargon.
class GlucoseAnalyzer {
  GlucoseAnalyzer._();
  static final GlucoseAnalyzer instance = GlucoseAnalyzer._();

  // ─── Sesli geri bildirim metinleri ─────────────────────
  static const String _hipoglisemi =
      'Kritik seviye tespit edildi. Hipoglisemi riski. '
      'Sistem karbonhidrat takviyesi öneriyor.';

  static const String _nominal =
      'Değerler nominal. Sistem stabil. Kayıt tamamlandı.';

  static const String _sinirDeger = 'Sınır değer. Takip protokolü devrede.';

  static const String _yuksekGlukoz =
      'Yüksek glukoz uyarısı. İnsülin kontrolü gerekli.';

  static const String _ea1cGuncellendi = '3 aylık ortalama güncellendi.';

  static const String _sdYuksek = 'Dikkat. Glikoz dalgalanması yüksek.';

  // ─── Bildirim payload sesli yanıtları ─────────────────
  static const String _aclikHatirlat =
      'Hatırlatma protokolü: Açlık şekeri ölçüm zamanı.';

  static const String _toklukHatirlat =
      'Hatırlatma protokolü: Yemekten 2 saat geçti. '
      'Tokluk verisi bekleniyor.';

  /// Kayıt sonrası tüm ölçümleri analiz et ve sesli geri bildirim ver.
  ///
  /// Her ölçüm ayrı ayrı değerlendirilir, en kritik seviye seslenir.
  Future<String> analyzeAndSpeak(GlucoseRecordEntity record) async {
    final measurements = record.allMeasurements.whereType<int>().toList();
    if (measurements.isEmpty) return _nominal;

    // En kritik ölçümü belirle
    final message = _classifyMostCritical(measurements);

    await SystemVoiceService.instance.speak(message);
    AppLogger.instance.info('GlucoseAnalyzer: $message');

    return message;
  }

  /// Tüm ölçümlerden en kritik olanın mesajını döndür.
  String _classifyMostCritical(List<int> values) {
    // Hipoglisemi öncelikli
    if (values.any((v) => v < 70)) return _hipoglisemi;

    // Yüksek glukoz
    if (values.any((v) => v > 180)) return _yuksekGlukoz;

    // Sınır değer
    if (values.any((v) => v > 100 && v <= 140)) return _sinirDeger;

    // Hepsi normal
    return _nominal;
  }

  /// Tek bir ölçümü sınıflandır.
  String classifySingle(int glucose) {
    if (glucose < 70) return _hipoglisemi;
    if (glucose <= 100) return _nominal;
    if (glucose <= 140) return _sinirDeger;
    return _yuksekGlukoz;
  }

  /// eA1c değişimi varsa sesli bildirim.
  Future<void> announceEa1cUpdate({
    required Ea1cResult? previousEa1c,
    required Ea1cResult? currentEa1c,
  }) async {
    if (currentEa1c == null) return;
    if (previousEa1c == null) {
      // İlk hesaplama
      await SystemVoiceService.instance.speak(
        'Tahmini A1C hesaplandı: yüzde ${currentEa1c.formattedEa1c}. '
        '$_ea1cGuncellendi',
      );
      return;
    }

    final diff = (currentEa1c.ea1c - previousEa1c.ea1c).abs();
    if (diff >= 0.1) {
      await SystemVoiceService.instance.speak(
        'Tahmini A1C güncellendi: yüzde ${currentEa1c.formattedEa1c}. '
        '$_ea1cGuncellendi',
      );
    }
  }

  /// Yüksek SD uyarısı.
  Future<void> announceHighVariability(GlucoseVariabilityResult? result) async {
    if (result == null) return;
    if (result.standardDeviation > 40) {
      await SystemVoiceService.instance.speak(_sdYuksek);
    }
  }

  /// Bildirim payload'ına göre sesli yanıt.
  Future<void> handleNotificationPayload(String? payload) async {
    if (payload == null) return;

    switch (payload) {
      case kPayloadToklukReminder:
        await SystemVoiceService.instance.speak(_toklukHatirlat);
        break;
      case kPayloadAclikReminder:
        await SystemVoiceService.instance.speak(_aclikHatirlat);
        break;
      default:
        AppLogger.instance.info(
          'GlucoseAnalyzer: Bilinmeyen payload: $payload',
        );
    }
  }
}
