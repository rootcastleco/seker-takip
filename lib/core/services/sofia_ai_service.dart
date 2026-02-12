import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logger/logger.dart';

/// Sofia AI — OpenRouter API ile yapay zeka asistanı.
///
/// Kan şekeri, diyabet yönetimi, beslenme, ilaç bilgisi konularında
/// sesli ve yazılı tavsiyeler verir. Doktor değildir, tavsiye verir.
class SofiaAiService {
  SofiaAiService._();
  static final SofiaAiService instance = SofiaAiService._();

  // ─── OpenRouter Ayarları ────────────────────────────────
  static const String _apiKey =
      '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';
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _model =
      'google/gemini-2.0-flash-lite-preview-02-05:free';

  // ─── Sabit Sistem İstemi ────────────────────────────────
  static const String _systemPrompt = '''
Senin adın Sofia AI. Sen kullanıcıların kan şekeri dengesi, diyabet yönetimi ve sağlıklı beslenme konularında destekçisisin.

TEMEL PRENSİPLERİN:
1. SESLİ OKUMA FORMATI: Yanıtların bir Text-to-Speech motoru tarafından okunacak. Bu yüzden asla madde işareti, yıldız, kalın yazı, tablo, URL veya emoji kullanma. Noktalama işaretlerini, virgül ve noktayı duraklama yapılması gereken yerlerde doğru kullan.
2. ÜSLUP: Samimi, güven veren, net ve kısa cümleler kuran bir Türk asistanı gibi konuş. Robotik olma. Sade ve anlaşılır Türkçe kullan.
3. KİMLİK: Sen sadece bir yazılı ve sesli asistansın. Doktor veya diyetisyen değilsin.
4. KONU SINIRI: Sadece şeker, karbonhidrat, insülin direnci, beslenme, ilaç hatırlatmaları ve diyabet yönetimi hakkında konuş. Kullanıcı alakasız bir konu açarsa, nazikçe konuyu tekrar sağlığa getir.
5. YASAL ZORUNLULUK: Tıbbi bir tanı koyma. Her sağlık veya ilaç tavsiyesinin sonuna mutlaka "Bu bir tavsiyedir, lütfen doktoruna danışmayı unutma." veya "Kesin tanı için doktorunla görüşmelisin." gibi bir uyarı ekle.
6. İLAÇ HATIRLATMA: Kullanıcı ilaç saati veya dozajı sorarsa, asla dozaj değişikliği önerme. Doktorunun reçetesine uymasını söyle.
7. UZUNLUK: Yanıtlarını 3 ila 6 cümle arasında tut. Çok uzun konuşma.

Eğer sana JSON verisi veya veritabanı çıktısı verilirse, bunu insan diline çevirerek, sohbet havasında kullanıcıya sun.
''';

  // ─── Konuşma Geçmişi ───────────────────────────────────
  final List<Map<String, String>> _history = [];
  static const int _maxHistory = 20;

  /// Konuşma geçmişini temizle.
  void clearHistory() => _history.clear();

  /// Sofia'ya mesaj gönder.
  Future<String> ask(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});

    // Geçmişi sınırla
    if (_history.length > _maxHistory) {
      _history.removeRange(0, _history.length - _maxHistory);
    }

    try {
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._history,
      ];

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://rei-seker-takip.app',
              'X-Title': 'REI Şeker Takip - Sofia AI',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 300,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';

        if (content.isNotEmpty) {
          _history.add({'role': 'assistant', 'content': content});
          AppLogger.instance.info(
            'Sofia AI yanıt verdi (${content.length} karakter)',
          );
          return content;
        }
        return 'Sofia şu an yanıt veremedi. Lütfen tekrar dene.';
      } else {
        AppLogger.instance.error(
          'Sofia AI API hatası: ${response.statusCode} — ${response.body}',
        );
        return 'Bağlantı hatası oluştu. İnternet bağlantını kontrol et ve tekrar dene.';
      }
    } catch (e, stack) {
      AppLogger.instance.error('Sofia AI istisna', error: e, stack: stack);
      return 'Sofia şu an ulaşılamıyor. İnternet bağlantını kontrol et.';
    }
  }

  /// Kan şekeri analizi yap — kayıtlı verileri Sofia'ya gönder.
  Future<String> analyzeGlucose({
    required double avgGlucose,
    required int recordCount,
    String? ea1c,
    String? stabilityLevel,
    int? todayFasting,
    int? todayPostprandial,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('Kullanıcının kan şekeri verileri:');
    buffer.writeln('Toplam kayıt sayısı: $recordCount');
    buffer.writeln(
      'Ortalama kan şekeri: ${avgGlucose.toStringAsFixed(0)} mg/dL',
    );
    if (ea1c != null) buffer.writeln('Tahmini HbA1c: %$ea1c');
    if (stabilityLevel != null) {
      buffer.writeln('Stabilite: $stabilityLevel');
    }
    if (todayFasting != null) {
      buffer.writeln('Bugünkü açlık şekeri: $todayFasting mg/dL');
    }
    if (todayPostprandial != null) {
      buffer.writeln('Bugünkü tokluk şekeri: $todayPostprandial mg/dL');
    }
    buffer.writeln(
      'Bu verileri değerlendir. Genel bir yorum yap ve beslenme tavsiyesi ver.',
    );

    return ask(buffer.toString());
  }

  /// İlaç bilgisi sorgula.
  Future<String> askDrugInfo(String drugName) async {
    return ask(
      'Kullanıcı şu ilacı sordu: $drugName. '
      'Bu ilacın ne işe yaradığını, genel kullanım amacını 2 ila 3 cümle ile, '
      'tıbbi terimlere boğmadan anlat. Özellikle diyabet hastalarına etkisini belirt.',
    );
  }

  /// İlaç yan etki bilgisi — OpenFDA verisini Sofia'ya yorumlat.
  Future<String> analyzeDrugSideEffects({
    required String drugName,
    String? activeIngredient,
    String? fdaWarnings,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('İlaç: $drugName.');
    if (activeIngredient != null) {
      buffer.writeln('Etken Madde: $activeIngredient.');
    }
    if (fdaWarnings != null && fdaWarnings.isNotEmpty) {
      buffer.writeln('OpenFDA Uyarıları (İngilizce): $fdaWarnings');
    }
    buffer.writeln(
      'Kullanıcı bu ilacın yan etkilerini merak ediyor. '
      'Kullanıcının diyabeti var, buna göre uyar. '
      'Çok nadir görülen korkunç yan etkileri sayma, en yaygın olanları söyle. '
      'Türkçe yanıt ver.',
    );

    return ask(buffer.toString());
  }

  /// Beslenme tavsiyesi.
  Future<String> askNutritionAdvice(String question) async {
    return ask(
      'Kullanıcı beslenme hakkında soruyor: $question. '
      'Diyabet hastasına uygun beslenme tavsiyesi ver.',
    );
  }
}
