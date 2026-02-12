import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants.dart';
import '../logger/logger.dart';

/// Bildirim servisi — Tokluk/Açlık hatırlatıcısı + payload desteği.
///
/// Bildirime tıklanınca [onNotificationTapped] callback tetiklenir,
/// bu callback aracılığıyla [GlucoseAnalyzer] sesli yanıt verir.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Bildirime tıklanınca tetiklenen callback.
  /// [main.dart] içinde set edilir, payload string gönderir.
  void Function(String? payload)? onNotificationTapped;

  /// Servisi başlat (main'de çağrılmalı).
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Uygulama kapalıyken tıklanan bildirim payload'ını kontrol et
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      // Kısa gecikme — uygulama tamamen ayağa kalksın
      Future.delayed(const Duration(seconds: 1), () {
        onNotificationTapped?.call(payload);
      });
    }

    _initialized = true;
    AppLogger.instance.info('NotificationService başlatıldı (payload-aware).');
  }

  void _onNotificationResponse(NotificationResponse response) {
    AppLogger.instance.info('Bildirim tıklandı. Payload: ${response.payload}');
    onNotificationTapped?.call(response.payload);
  }

  /// Android bildirim izni iste.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    // iOS izinleri init sırasında istenir
    return true;
  }

  /// [kToklukRemindMinutes] dakika sonra tokluk hatırlatıcısı kur.
  Future<void> scheduleToklukReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        kNotifChannelId,
        kNotifChannelName,
        channelDescription: 'Tokluk ölçüm hatırlatıcıları',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Tokluk ölçüm zamanı',
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Dart Timer ile zamanlı bildirim
      Future.delayed(const Duration(minutes: kToklukRemindMinutes), () async {
        await _plugin.show(
          kNotifToklukId,
          kAppName,
          Tr.toklukBildirimi,
          details,
          payload: kPayloadToklukReminder,
        );
      });

      AppLogger.instance.info(
        'Tokluk hatırlatıcısı kuruldu: $kToklukRemindMinutes dk sonra. '
        'Payload: $kPayloadToklukReminder',
      );
    } catch (e, stack) {
      AppLogger.instance.error('Bildirim hatası', error: e, stack: stack);
    }
  }

  /// Açlık hatırlatıcısı (opsiyonel).
  Future<void> showAclikReminder() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        kNotifChannelId,
        kNotifChannelName,
        channelDescription: 'Açlık ölçüm hatırlatıcıları',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(
        kNotifAclikId,
        kAppName,
        'Açlık şekeri ölçüm zamanı.',
        details,
        payload: kPayloadAclikReminder,
      );
    } catch (e, stack) {
      AppLogger.instance.error('Açlık bildirim hatası', error: e, stack: stack);
    }
  }

  /// Bekleyen bildirimleri iptal et.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
