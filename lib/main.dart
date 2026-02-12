import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'app/app.dart';
import 'core/logger/logger.dart';
import 'core/services/notification_service.dart';
import 'core/services/voice_service.dart';
import 'features/dashboard/logic/glucose_analyzer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger başlat
  final appDir = await getApplicationDocumentsDirectory();
  final logDir = path.join(appDir.path, 'logs');
  await AppLogger.instance.init(logDir);
  AppLogger.instance.info('Uygulama başlatılıyor...');

  // Sistem sesi (TTS) başlat
  await SystemVoiceService.instance.init();

  // Bildirim servisi başlat
  await NotificationService.instance.init();

  // Bildirim tıklama → GlucoseAnalyzer sesli yanıt
  NotificationService.instance.onNotificationTapped = (payload) {
    GlucoseAnalyzer.instance.handleNotificationPayload(payload);
  };

  // Flutter hata yakalayıcıları
  FlutterError.onError = (details) {
    AppLogger.instance.error(
      'FlutterError: ${details.exceptionAsString()}',
      error: details.exception,
      stack: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('PlatformError', error: error, stack: stack);
    return true;
  };

  runApp(const ProviderScope(child: SekerTakipApp()));
}
