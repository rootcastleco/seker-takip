import 'dart:convert';
import 'dart:io';

import '../../core/checksum/canonical_json.dart';
import '../../core/checksum/sha256.dart';
import '../../core/constants.dart';
import '../../domain/entities/glucose_record.dart';
import '../../domain/entities/profile.dart';

/// NASA kalitesinde JSON Backup dışa aktarımı (checksum'lu).
class JsonBackupExporter {
  /// Backup JSON string oluşturur.
  static String generate({
    required ProfileEntity profile,
    required List<GlucoseRecordEntity> records,
    String? notes,
  }) {
    final exportedAtUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Checksum hesaplanacak olan payload (checksum hariç)
    final payload = <String, dynamic>{
      'checksumAlgo': 'sha256',
      'exportedAtUtcMillis': exportedAtUtcMillis,
      'notes': notes,
      'profile': profile.toMap(),
      'recordCount': records.length,
      'records': records.map((r) => r.toMap()).toList(),
      'schemaVersion': kSchemaVersion,
    };

    // Canonical bytes → SHA-256
    final canonicalBytes = canonicalJsonBytes(payload);
    final checksum = sha256Hex(canonicalBytes);

    // Tam backup nesnesi
    final backup = <String, dynamic>{...payload, 'checksum': checksum};

    // Son çıktı: canonical JSON (güzel baskı)
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(backup);
  }

  /// Dosyaya yazar.
  static Future<File> writeToFile({
    required ProfileEntity profile,
    required List<GlucoseRecordEntity> records,
    required String filePath,
    String? notes,
  }) async {
    final json = generate(profile: profile, records: records, notes: notes);
    final file = File(filePath);
    return file.writeAsString(json);
  }
}
