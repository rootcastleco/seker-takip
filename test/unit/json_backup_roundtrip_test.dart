import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/data/export_import/json_backup_exporter.dart';
import 'package:seker_takip/data/export_import/json_backup_importer.dart';
import 'package:seker_takip/domain/entities/profile.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  final now = DateTime.now();
  final profile = ProfileEntity(
    id: 1,
    isimSoyisim: 'Test Kişi',
    yas: 45,
    kilo: 78.5,
    doktor: 'Dr. Test',
    diyabetEgitimHemsiresi: 'Hemşire Test',
    cepTelefonu: '+905551234567',
    adres: 'Test Mah. 123 Sok.',
    createdAt: now,
    updatedAt: now,
  );

  final records = [
    GlucoseRecordEntity(
      id: 1,
      tarih: DateTime(2025, 1, 15),
      sabahAc: 95,
      sabahTok: 130,
      oglenAc: 88,
      oglenTok: 145,
      aksamAc: 102,
      aksamTok: 155,
      yatmadanOnce: 120,
      gece03: 85,
      ilacInsulinAdi: 'Metformin 500mg',
      notlar: 'Normal gün',
      createdAt: now,
      updatedAt: now,
    ),
    GlucoseRecordEntity(
      id: 2,
      tarih: DateTime(2025, 1, 14),
      sabahAc: 110,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  group('JSON Backup roundtrip', () {
    test('export→import eşdeğerlik: kayıt sayısı korunmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      final result = JsonBackupImporter.parse(json);
      expect(result.recordCount, records.length);
      expect(result.records.length, records.length);
    });

    test('export→import eşdeğerlik: profil korunmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      final result = JsonBackupImporter.parse(json);
      expect(result.profile, isNotNull);
      expect(result.profile!.isimSoyisim, profile.isimSoyisim);
      expect(result.profile!.yas, profile.yas);
      expect(result.profile!.kilo, profile.kilo);
      expect(result.profile!.doktor, profile.doktor);
    });

    test('export→import eşdeğerlik: kayıt verileri korunmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      final result = JsonBackupImporter.parse(json);
      final r0 = result.records[0];
      expect(r0.sabahAc, 95);
      expect(r0.sabahTok, 130);
      expect(r0.ilacInsulinAdi, 'Metformin 500mg');
      expect(r0.notlar, 'Normal gün');
    });

    test('checksum doğrulama başarılı olmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      // parse checksum'u doğrular, hata fırlatmamalı
      expect(() => JsonBackupImporter.parse(json), returnsNormally);
    });

    test('bozuk checksum ImportException fırlatmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      // Checksum'u boz
      final corrupted = json.replaceFirst(
        RegExp(r'"checksum":\s*"[a-f0-9]+"'),
        '"checksum": "0000000000000000000000000000000000000000000000000000000000000000"',
      );
      expect(
        () => JsonBackupImporter.parse(corrupted),
        throwsA(isA<ImportException>()),
      );
    });

    test('yanlış schemaVersion ImportException fırlatmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      final wrongVersion = json.replaceFirst(
        '"schemaVersion": 1',
        '"schemaVersion": 99',
      );
      expect(
        () => JsonBackupImporter.parse(wrongVersion),
        throwsA(isA<ImportException>()),
      );
    });

    test('geçersiz JSON ImportException fırlatmalı', () {
      expect(
        () => JsonBackupImporter.parse('not json'),
        throwsA(isA<ImportException>()),
      );
    });

    test('null alanlar korunmalı', () {
      final json = JsonBackupExporter.generate(
        profile: profile,
        records: records,
      );
      final result = JsonBackupImporter.parse(json);
      final r1 = result.records[1];
      expect(r1.sabahTok, isNull);
      expect(r1.oglenAc, isNull);
      expect(r1.notlar, isNull);
    });
  });
}
