import 'package:intl/intl.dart';

/// Tarih formatı: dd.MM.yyyy (Türkçe kullanıcı).
String formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

/// Tarih+Saat formatı: dd.MM.yyyy HH:mm
String formatDateTime(DateTime date) =>
    DateFormat('dd.MM.yyyy HH:mm').format(date);

/// Export dosya tarih eki: yyyyMMdd_HHmm
String formatExportTimestamp(DateTime date) =>
    DateFormat('yyyyMMdd_HHmm').format(date);

/// mg/dL gösterimi. null ise "–" döner.
String formatGlucose(int? value) => value != null ? '$value' : '–';

/// UTC millis ↔ DateTime dönüşümleri
int toUtcMillis(DateTime dt) => dt.toUtc().millisecondsSinceEpoch;
DateTime fromUtcMillis(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
