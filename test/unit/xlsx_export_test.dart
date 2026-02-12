import 'package:flutter_test/flutter_test.dart';
import 'package:seker_takip/data/export_import/xlsx_exporter.dart';
import 'package:seker_takip/domain/entities/glucose_record.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);
  final records = [
    GlucoseRecordEntity(
      id: 1,
      tarih: DateTime(2025, 1, 15),
      sabahAc: 95,
      sabahTok: 130,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  group('XlsxExporter', () {
    test('boş olmayan byte dizisi üretmeli', () {
      final bytes = XlsxExporter.generate(records);
      expect(bytes, isNotEmpty);
    });

    test('boş kayıt listesi de geçerli xlsx üretmeli', () {
      final bytes = XlsxExporter.generate([]);
      expect(bytes, isNotEmpty);
    });

    test('xlsx magic bytes doğru olmalı (PK zip başlangıcı)', () {
      final bytes = XlsxExporter.generate(records);
      // XLSX aslında bir ZIP dosyasıdır: PK\x03\x04
      expect(bytes[0], 0x50); // P
      expect(bytes[1], 0x4B); // K
    });
  });
}
