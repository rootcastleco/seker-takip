import 'dart:convert';
import 'dart:io';

import '../../core/checksum/canonical_json.dart';
import '../../core/checksum/sha256.dart';
import '../../core/constants.dart';
import '../../domain/entities/glucose_record.dart';
import '../../domain/entities/profile.dart';

/// JSON Backup içe aktarma sonucu.
class ImportResult {
  final ProfileEntity? profile;
  final List<GlucoseRecordEntity> records;
  final int recordCount;
  final DateTime exportedAt;

  const ImportResult({
    this.profile,
    required this.records,
    required this.recordCount,
    required this.exportedAt,
  });
}

/// JSON Backup içe aktarma hataları.
class ImportException implements Exception {
  final String message;
  const ImportException(this.message);

  @override
  String toString() => message;
}

/// NASA kalitesinde JSON Backup içe aktarımı (checksum doğrulamalı).
class JsonBackupImporter {
  /// JSON string parse + doğrulama.
  static ImportResult parse(String jsonString) {
    final Map<String, dynamic> data;
    try {
      data = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw const ImportException('Geçersiz JSON formatı.');
    }

    // 1) schemaVersion kontrolü
    final schemaVersion = data['schemaVersion'] as int?;
    if (schemaVersion == null || schemaVersion != kSchemaVersion) {
      throw ImportException(Tr.semaUyumsuz);
    }

    // 2) Checksum doğrulama
    final receivedChecksum = data['checksum'] as String?;
    if (receivedChecksum == null) {
      throw const ImportException('Checksum bilgisi bulunamadı.');
    }

    // Checksum hariç payload oluştur (aynı alan sırasıyla)
    final payload = <String, dynamic>{
      'checksumAlgo': data['checksumAlgo'],
      'exportedAtUtcMillis': data['exportedAtUtcMillis'],
      'notes': data['notes'],
      'profile': data['profile'],
      'recordCount': data['recordCount'],
      'records': data['records'],
      'schemaVersion': data['schemaVersion'],
    };

    final canonicalBytes = canonicalJsonBytes(payload);
    final computedChecksum = sha256Hex(canonicalBytes);

    if (computedChecksum != receivedChecksum) {
      throw ImportException(Tr.checksumHata);
    }

    // 3) Verileri parse et
    final profileMap = data['profile'] as Map<String, dynamic>?;
    final recordsList = data['records'] as List<dynamic>? ?? [];
    final exportedAtMillis = data['exportedAtUtcMillis'] as int;

    final profile = profileMap != null
        ? ProfileEntity.fromMap(profileMap)
        : null;

    final records = recordsList
        .map((r) => GlucoseRecordEntity.fromMap(r as Map<String, dynamic>))
        .toList();

    return ImportResult(
      profile: profile,
      records: records,
      recordCount: data['recordCount'] as int? ?? records.length,
      exportedAt: DateTime.fromMillisecondsSinceEpoch(
        exportedAtMillis,
        isUtc: true,
      ),
    );
  }

  /// Dosyadan okuyup parse eder.
  static Future<ImportResult> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ImportException('Dosya bulunamadı.');
    }
    final content = await file.readAsString();
    return parse(content);
  }
}
