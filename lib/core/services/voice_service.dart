import 'package:flutter_tts/flutter_tts.dart';
import '../logger/logger.dart';

/// Rootcastle Sistem Sesi — "Mainframe AI" tarzı TTS servisi.
///
/// Persona: Robotik, düz, otoriter. Tamamen Türkçe.
/// Pitch: 0.6  |  Rate: 0.45  |  Language: tr-TR
///
/// Kural: Mesajlar kuyruklanır, üst üste binmez. `await speak()` ile çağrılır.
class SystemVoiceService {
  SystemVoiceService._();
  static final SystemVoiceService instance = SystemVoiceService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  // ─── TTS parametreleri ─────────────────────────────────
  static const double _pitch = 0.6;
  static const double _rate = 0.45;
  static const String _language = 'tr-TR';

  /// Servisi başlat. [main] içinde çağrılmalı.
  Future<void> init() async {
    if (_initialized) return;

    try {
      await _tts.setLanguage(_language);
      await _tts.setPitch(_pitch);
      await _tts.setSpeechRate(_rate);
      await _tts.setVolume(1.0);

      // Android motoru
      final engines = await _tts.getEngines;
      if (engines is List && engines.isNotEmpty) {
        AppLogger.instance.info('TTS Engines: $engines');
      }

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        AppLogger.instance.error('TTS Error: $msg');
      });

      _initialized = true;
      AppLogger.instance.info(
        'SystemVoiceService başlatıldı. '
        'Pitch=$_pitch, Rate=$_rate, Lang=$_language',
      );
    } catch (e, stack) {
      AppLogger.instance.error('TTS init hatası', error: e, stack: stack);
    }
  }

  /// Mesajı seslendir. Kuyruk mantığı ile çalışır — önceki bitmeden bekler.
  Future<void> speak(String message) async {
    if (!_initialized) {
      AppLogger.instance.warn('TTS henüz başlatılmadı, speak atlanıyor.');
      return;
    }

    // Önceki konuşma bitene kadar bekle
    while (_isSpeaking) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      _isSpeaking = true;
      AppLogger.instance.info('TTS Speak: "$message"');
      await _tts.speak(message);
    } catch (e, stack) {
      _isSpeaking = false;
      AppLogger.instance.error('TTS speak hatası', error: e, stack: stack);
    }
  }

  /// Konuşmayı hemen kes.
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  /// TTS kullanılabilir mi? (cihaz susturulmuş olabilir)
  bool get isAvailable => _initialized;

  /// Kaynak temizliği.
  Future<void> dispose() async {
    await _tts.stop();
    _initialized = false;
  }
}
