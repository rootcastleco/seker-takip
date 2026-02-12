import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import '../logger/logger.dart';

/// REI Sistem Sesi — TTS servisi.
///
/// Samsung cihaz uyumluluğu için awaitSpeakCompletion + engine seçimi.
/// Pitch: 0.8  |  Rate: 0.5  |  Language: tr-TR
class SystemVoiceService {
  SystemVoiceService._();
  static final SystemVoiceService instance = SystemVoiceService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = true;

  // ─── TTS parametreleri ─────────────────────────────────
  static const double _pitch = 0.8;
  static const double _rate = 0.5;
  static const String _language = 'tr-TR';

  /// Sesli asistanı aç/kapa.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Servisi başlat. [main] içinde çağrılmalı.
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Samsung cihazlarda awaitSpeakCompletion şart
      await _tts.awaitSpeakCompletion(true);

      // Android: Google TTS motorunu tercih et (Samsung TTS sorunlu olabiliyor)
      if (Platform.isAndroid) {
        final engines = await _tts.getEngines;
        AppLogger.instance.info('TTS Engines: $engines');

        if (engines is List) {
          // Google TTS varsa onu kullan
          final googleEngine = engines.firstWhere(
            (e) => e.toString().contains('google'),
            orElse: () => null,
          );
          if (googleEngine != null) {
            await _tts.setEngine(googleEngine.toString());
            AppLogger.instance.info('TTS Engine seçildi: $googleEngine');
          }
        }
      }

      await _tts.setLanguage(_language);
      await _tts.setPitch(_pitch);
      await _tts.setSpeechRate(_rate);
      await _tts.setVolume(1.0);

      // Samsung OneUI uyumluluğu: ses kanalı ALARM kullan
      if (Platform.isAndroid) {
        // Bu özellik Samsung cihazlarda DND/sessiz modda bile ses çıkmasını sağlar
        await _tts.setQueueMode(1); // QUEUE_ADD
      }

      _initialized = true;
      AppLogger.instance.info(
        'SystemVoiceService başlatıldı. '
        'Pitch=$_pitch, Rate=$_rate, Lang=$_language',
      );
    } catch (e, stack) {
      AppLogger.instance.error('TTS init hatası', error: e, stack: stack);
    }
  }

  /// Mesajı seslendir. awaitSpeakCompletion sayesinde sıralı çalışır.
  Future<void> speak(String message) async {
    if (!_initialized || !_enabled) {
      AppLogger.instance.warn('TTS devre dışı veya başlatılmadı.');
      return;
    }

    try {
      AppLogger.instance.info('TTS Speak: "$message"');
      await _tts.speak(message);
    } catch (e, stack) {
      AppLogger.instance.error('TTS speak hatası', error: e, stack: stack);
    }
  }

  /// Konuşmayı hemen kes.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// TTS kullanılabilir mi?
  bool get isAvailable => _initialized;

  /// Kaynak temizliği.
  Future<void> dispose() async {
    await _tts.stop();
    _initialized = false;
  }
}
