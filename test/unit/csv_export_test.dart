import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/data/export_import/csv_exporter.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);
  final records = [
    GlucoseRecordEntity(
      id: 1,
      tarih: DateTime(2025, 1, 15),
      sabahAc: 95,
      sabahTok: 130,
      oglenAc: null,
      oglenTok: null,
      aksamAc: 110,
      aksamTok: 150,
      yatmadanOnce: 120,
      gece03: null,
      ilacInsulinAdi: 'Metformin',
      notlar: 'Normal gün',
      createdAt: now,
      updatedAt: now,
    ),
    GlucoseRecordEntity(
      id: 2,
      tarih: DateTime(2025, 1, 14),
      sabahAc: 88,
      sabahTok: null,
      oglenAc: null,
      oglenTok: null,
      aksamAc: null,
      aksamTok: null,
      yatmadanOnce: null,
      gece03: 72,
      notlar: null,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  group('CsvExporter', () {
    test('header satırı doğru olmalı', () {
      final csv = CsvExporter.generate(records);
      final lines = csv.split('\n');
      expect(
        lines[0].trim(),
        'Tarih,Sabah Aç,Sabah Tok (2s),Öğlen Aç,Öğlen Tok (2s),'
        'Akşam Aç,Akşam Tok (2s),Yatmadan Önce,Gece 03:00,Not,İlaç/İnsülin Adı',
      );
    });

    test('doğru sayıda satır olmalı (header + veri)', () {
      final csv = CsvExporter.generate(records);
      final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
      expect(lines.length, 3); // header + 2 kayıt
    });

    test('null değerler boş bırakılmalı', () {
      final csv = CsvExporter.generate(records);
      final lines = csv.split('\n');
      // İkinci kayıt: sabahTok null → boş alan
      final secondRow = lines[2];
      expect(secondRow.contains(',,'), isTrue);
    });

    test('boş kayıt listesi sadece header döndürmeli', () {
      final csv = CsvExporter.generate([]);
      final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
      expect(lines.length, 1);
    });
  });
}
