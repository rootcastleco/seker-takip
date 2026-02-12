import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logger/logger.dart';

/// OpenFDA API servisi — İlaç bilgisi sorgulama.
///
/// Etken madde, uyarılar ve yan etki bilgisini FDA'dan çeker.
/// Sonuçlar İngilizce gelir, Sofia AI Türkçeye çevirir.
class OpenFdaService {
  OpenFdaService._();
  static final OpenFdaService instance = OpenFdaService._();

  static const String _baseUrl = 'https://api.fda.gov/drug';

  /// İlaç adı ile FDA'dan bilgi getir.
  /// Dönen Map: { 'brand_name', 'generic_name', 'purpose', 'warnings', 'active_ingredient' }
  Future<Map<String, String>?> searchDrug(String drugName) async {
    try {
      // OpenFDA label endpoint — ilaç etiketi bilgisi
      final url = Uri.parse(
        '$_baseUrl/label.json?search=openfda.brand_name:"$drugName"&limit=1',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final drug = results[0];
          final openFda = drug['openfda'] as Map<String, dynamic>? ?? {};

          return {
            'brand_name': _extractFirst(openFda['brand_name']),
            'generic_name': _extractFirst(openFda['generic_name']),
            'active_ingredient': _extractFirst(
              openFda['substance_name'] ?? drug['active_ingredient'],
            ),
            'purpose': _extractFirst(drug['purpose']),
            'warnings': _extractFirst(drug['warnings']),
            'indications_and_usage': _extractFirst(
              drug['indications_and_usage'],
            ),
            'dosage_and_administration': _extractFirst(
              drug['dosage_and_administration'],
            ),
          };
        }
      }

      // Brand name ile bulamadıysa generic name ile dene
      final genericUrl = Uri.parse(
        '$_baseUrl/label.json?search=openfda.generic_name:"$drugName"&limit=1',
      );

      final genericResponse = await http
          .get(genericUrl)
          .timeout(const Duration(seconds: 10));

      if (genericResponse.statusCode == 200) {
        final data = jsonDecode(genericResponse.body);
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final drug = results[0];
          final openFda = drug['openfda'] as Map<String, dynamic>? ?? {};

          return {
            'brand_name': _extractFirst(openFda['brand_name']),
            'generic_name': _extractFirst(openFda['generic_name']),
            'active_ingredient': _extractFirst(
              openFda['substance_name'] ?? drug['active_ingredient'],
            ),
            'purpose': _extractFirst(drug['purpose']),
            'warnings': _extractFirst(drug['warnings']),
            'indications_and_usage': _extractFirst(
              drug['indications_and_usage'],
            ),
            'dosage_and_administration': _extractFirst(
              drug['dosage_and_administration'],
            ),
          };
        }
      }

      AppLogger.instance.info('OpenFDA: "$drugName" bulunamadı.');
      return null;
    } catch (e, stack) {
      AppLogger.instance.error('OpenFDA hatası', error: e, stack: stack);
      return null;
    }
  }

  /// İlaç yan etki raporları — adverse events.
  Future<int> getAdverseEventCount(String genericName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/event.json?search=patient.drug.openfda.generic_name:"$genericName"&count=receivedate',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        // Toplam rapor sayısı
        int total = 0;
        for (final r in results) {
          total += (r['count'] as int? ?? 0);
        }
        return total;
      }
      return 0;
    } catch (e) {
      AppLogger.instance.warn('OpenFDA adverse event hatası: $e');
      return 0;
    }
  }

  /// List/String field'dan ilk değeri çıkar.
  String _extractFirst(dynamic value) {
    if (value == null) return '';
    if (value is List && value.isNotEmpty) {
      final first = value[0].toString();
      // Çok uzun metinleri kısalt (1000 karakter)
      return first.length > 1000 ? first.substring(0, 1000) : first;
    }
    if (value is String) {
      return value.length > 1000 ? value.substring(0, 1000) : value;
    }
    return value.toString();
  }
}
