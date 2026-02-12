import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants.dart';
import '../../core/formatting.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/glucose_record.dart';
import '../../domain/usecases/ea1c_calculator.dart';

/// Profesyonel PDF rapor oluşturucu — Türkçe karakter destekli.
class PdfReportGenerator {
  PdfReportGenerator._();

  static const _rootcastleBlue = PdfColor.fromInt(0xFF0E3D8A);
  static const _red = PdfColor.fromInt(0xFFD32F2F);

  /// Türkçe karakter destekleyen font yükle (asset'ten).
  static Future<pw.Font> _loadTurkishFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  static Future<pw.Font> _loadTurkishFontBold() async {
    try {
      final data = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helveticaBold();
    }
  }

  /// PDF dosyası oluştur.
  static Future<void> writeToFile({
    required ProfileEntity profile,
    required List<GlucoseRecordEntity> records,
    required String filePath,
  }) async {
    // Türkçe karakter destekli fontlar yükle
    final trFont = await _loadTurkishFont();
    final trFontBold = await _loadTurkishFontBold();

    final pdf = pw.Document(
      author: Tr.gelistiriciAdi,
      title: Tr.pdfRaporBaslik,
      creator: kAppName,
      theme: pw.ThemeData.withFont(base: trFont, bold: trFontBold),
    );

    final ea1cResult = Ea1cCalculator.calculate(records);
    final sdResult = Ea1cCalculator.calculateVariability(records);

    // Genel istatistikler
    final allVals = records
        .expand((r) => r.allMeasurements)
        .whereType<int>()
        .toList();
    final avgGlucose = allVals.isNotEmpty
        ? (allVals.reduce((a, b) => a + b) / allVals.length)
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Hasta bilgileri
          _buildPatientInfo(profile),
          pw.SizedBox(height: 16),

          // Özet kartları
          _buildSummarySection(
            records: records,
            avgGlucose: avgGlucose,
            ea1cResult: ea1cResult,
            sdResult: sdResult,
          ),
          pw.SizedBox(height: 16),

          // Ölçüm tablosu
          if (records.isNotEmpty) ...[
            pw.Text(
              Tr.pdfOlcumTablosu,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _rootcastleBlue,
              ),
            ),
            pw.SizedBox(height: 8),
            _buildRecordTable(records),
            pw.SizedBox(height: 8),
            pw.Text(
              Tr.pdfHedefDisiBilgi,
              style: pw.TextStyle(fontSize: 8, color: _red),
            ),
          ],
        ],
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _rootcastleBlue, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                Tr.pdfHeaderOrg,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _rootcastleBlue,
                ),
              ),
              pw.Text(
                'Dev: ${Tr.gelistiriciAdi}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${Tr.pdfOlusturmaTarihi}: ${formatDate(DateTime.now())}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                'v$kAppVersion',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            Tr.pdfFooterGen,
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(ProfileEntity profile) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            Tr.pdfHastaBilgi,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _rootcastleBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          _infoRow(
            Tr.isimSoyisim,
            profile.isimSoyisim.isNotEmpty ? profile.isimSoyisim : '-',
          ),
          _infoRow(Tr.yas, profile.yas > 0 ? '${profile.yas}' : '-'),
          _infoRow(Tr.kilo, profile.kilo > 0 ? '${profile.kilo} kg' : '-'),
          _infoRow(Tr.doktor, profile.doktor.isNotEmpty ? profile.doktor : '-'),
          _infoRow(
            Tr.diyabetEgitimHemsiresi,
            profile.diyabetEgitimHemsiresi.isNotEmpty
                ? profile.diyabetEgitimHemsiresi
                : '-',
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection({
    required List<GlucoseRecordEntity> records,
    required double avgGlucose,
    required Ea1cResult? ea1cResult,
    required GlucoseVariabilityResult? sdResult,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _rootcastleBlue, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            Tr.pdfOzet,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _rootcastleBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          _infoRow(Tr.pdfToplamKayit, '${records.length}'),
          _infoRow(
            Tr.pdfOrtalamaGlukoz,
            '${avgGlucose.toStringAsFixed(0)} mg/dL',
          ),
          if (ea1cResult != null)
            _infoRow(Tr.ea1cBaslik, '%${ea1cResult.formattedEa1c}'),
          if (sdResult != null)
            _infoRow(Tr.standartSapma, '${sdResult.formattedSD} mg/dL'),
          if (sdResult != null)
            _infoRow(Tr.stabiliteBaslik, _stabilityText(sdResult.level)),
        ],
      ),
    );
  }

  static String _stabilityText(StabilityLevel level) {
    switch (level) {
      case StabilityLevel.stable:
        return Tr.stabiliteDusuk;
      case StabilityLevel.moderate:
        return Tr.stabiliteOrta;
      case StabilityLevel.high:
        return Tr.stabiliteYuksek;
    }
  }

  static pw.Widget _buildRecordTable(List<GlucoseRecordEntity> records) {
    final headers = [
      Tr.tarih,
      Tr.sabahAc,
      Tr.sabahTok,
      Tr.oglenAc,
      Tr.oglenTok,
      Tr.aksamAc,
      Tr.aksamTok,
      'Yat.',
      '03:00',
    ];

    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.center,
      headerAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: _rootcastleBlue),
      cellStyle: pw.TextStyle(fontSize: 8),
      cellHeight: 22,
      columnWidths: {0: const pw.FixedColumnWidth(60)},
      headers: headers,
      data: records.map((r) {
        return [
          formatDate(r.tarih),
          _cellVal(r.sabahAc, isFasting: true),
          _cellVal(r.sabahTok),
          _cellVal(r.oglenAc, isFasting: true),
          _cellVal(r.oglenTok),
          _cellVal(r.aksamAc, isFasting: true),
          _cellVal(r.aksamTok),
          _cellVal(r.yatmadanOnce),
          _cellVal(r.gece03),
        ];
      }).toList(),
    );
  }

  static String _cellVal(int? value, {bool isFasting = false}) {
    if (value == null) return '-';
    final threshold = isFasting ? kTargetAksFasting : kTargetPostprandial;
    // Kırmızı gösterim için metin ile işaretle
    if (value > threshold) return '⚠$value';
    return '$value';
  }
}
