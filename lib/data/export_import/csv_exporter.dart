import 'dart:io';
import '../../domain/entities/glucose_record.dart';
import '../../core/formatting.dart';

/// CSV dışa aktarımı.
class CsvExporter {
  static const _header =
      'Tarih,Sabah Aç,Sabah Tok (2s),Öğlen Aç,Öğlen Tok (2s),'
      'Akşam Aç,Akşam Tok (2s),Yatmadan Önce,Gece 03:00,Not,İlaç/İnsülin Adı';

  /// CSV string oluşturur.
  static String generate(List<GlucoseRecordEntity> records) {
    final buffer = StringBuffer();
    buffer.writeln(_header);
    for (final r in records) {
      buffer.writeln(
        [
          formatDate(r.tarih),
          r.sabahAc ?? '',
          r.sabahTok ?? '',
          r.oglenAc ?? '',
          r.oglenTok ?? '',
          r.aksamAc ?? '',
          r.aksamTok ?? '',
          r.yatmadanOnce ?? '',
          r.gece03 ?? '',
          _escapeCsv(r.notlar ?? ''),
          _escapeCsv(r.ilacInsulinAdi ?? ''),
        ].join(','),
      );
    }
    return buffer.toString();
  }

  /// CSV dosyasına yazar.
  static Future<File> writeToFile(
    List<GlucoseRecordEntity> records,
    String filePath,
  ) async {
    final csv = generate(records);
    final file = File(filePath);
    return file.writeAsString(csv);
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
