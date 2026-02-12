import 'dart:io';
import 'package:excel/excel.dart';
import '../../domain/entities/glucose_record.dart';
import '../../core/formatting.dart';

/// Excel (.xlsx) dışa aktarımı.
class XlsxExporter {
  static const _sheetName = 'Kayıtlar';

  static final _headers = [
    'Tarih',
    'Sabah Aç',
    'Sabah Tok (2s)',
    'Öğlen Aç',
    'Öğlen Tok (2s)',
    'Akşam Aç',
    'Akşam Tok (2s)',
    'Yatmadan Önce',
    'Gece 03:00',
    'Not',
    'İlaç/İnsülin Adı',
  ];

  /// Excel bytes oluşturur.
  static List<int> generate(List<GlucoseRecordEntity> records) {
    final excel = Excel.createExcel();
    excel.rename(excel.getDefaultSheet()!, _sheetName);
    final sheet = excel[_sheetName];

    // Header satırı (bold)
    for (var i = 0; i < _headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(_headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Veri satırları
    for (var rowIdx = 0; rowIdx < records.length; rowIdx++) {
      final r = records[rowIdx];
      final row = <CellValue?>[
        TextCellValue(formatDate(r.tarih)),
        r.sabahAc != null ? IntCellValue(r.sabahAc!) : null,
        r.sabahTok != null ? IntCellValue(r.sabahTok!) : null,
        r.oglenAc != null ? IntCellValue(r.oglenAc!) : null,
        r.oglenTok != null ? IntCellValue(r.oglenTok!) : null,
        r.aksamAc != null ? IntCellValue(r.aksamAc!) : null,
        r.aksamTok != null ? IntCellValue(r.aksamTok!) : null,
        r.yatmadanOnce != null ? IntCellValue(r.yatmadanOnce!) : null,
        r.gece03 != null ? IntCellValue(r.gece03!) : null,
        TextCellValue(r.notlar ?? ''),
        TextCellValue(r.ilacInsulinAdi ?? ''),
      ];
      for (var colIdx = 0; colIdx < row.length; colIdx++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 1),
        );
        cell.value = row[colIdx];
      }
    }

    return excel.encode()!;
  }

  /// Excel dosyasına yazar.
  static Future<File> writeToFile(
    List<GlucoseRecordEntity> records,
    String filePath,
  ) async {
    final bytes = generate(records);
    final file = File(filePath);
    return file.writeAsBytes(bytes);
  }
}
