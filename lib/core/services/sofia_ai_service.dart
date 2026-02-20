import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../logger/logger.dart';

/// Sofia AI — Google Gemini API ile yapay zeka asistanı.
///
/// Kan şekeri, diyabet yönetimi, beslenme, ilaç bilgisi, yemek analizi,
/// acil durum desteği ve biohacking koçluğu.
class SofiaAiService {
  SofiaAiService._();
  static final SofiaAiService instance = SofiaAiService._();

  static const String _prefApiKey = 'sofia_api_key';
  static const String _prefModel = 'sofia_model';

  static const String defaultApiKey = 'AIzaSyAf-u-aqdJcqwcz0jiITMpN15FC8gEsaYs';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String defaultModel = 'gemini-2.0-flash';

  /// Kullanılabilir Gemini modelleri.
  static const List<SofiaModel> availableModels = [
    SofiaModel(id: 'gemini-2.0-flash', name: 'Gemini 2.0 Flash'),
    SofiaModel(id: 'gemini-2.0-flash-lite', name: 'Gemini 2.0 Flash Lite'),
    SofiaModel(id: 'gemini-1.5-flash', name: 'Gemini 1.5 Flash'),
    SofiaModel(id: 'gemini-1.5-pro', name: 'Gemini 1.5 Pro'),
  ];

  String _apiKey = defaultApiKey;
  String _model = defaultModel;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_prefApiKey) ?? defaultApiKey;
      _model = prefs.getString(_prefModel) ?? defaultModel;
      final modelExists = availableModels.any((m) => m.id == _model);
      if (!modelExists) {
        _model = defaultModel;
        await prefs.setString(_prefModel, _model);
      }
      AppLogger.instance.info('Sofia AI: Model=$_model');
    } catch (e) {
      AppLogger.instance.error('Sofia ayar hatasi: $e');
    }
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim().isNotEmpty ? key.trim() : defaultApiKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, _apiKey);
  }

  Future<void> setModel(String modelId) async {
    _model = modelId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModel, _model);
  }

  String get maskedApiKey {
    if (_apiKey.length <= 12) return '****';
    return '${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}';
  }

  String get currentModel => _model;

  String get currentModelName {
    for (final m in availableModels) {
      if (m.id == _model) return m.name;
    }
    return _model;
  }

  // ─── Sistem İstemleri ───────────────────────────────────

  static const String _systemPrompt = '''
Senin adin Sofia. Sen bir yapay zeka saglik asistanisin. Diyabet yonetimi, kan sekeri takibi, beslenme ve ilac konularinda yardim ediyorsun.

KURALLAR:
1. Samimi, sicak, guven veren bir arkadas gibi konus. Kisa ve net cumleler kur. Dogal Turkce kullan.
2. Yanitlarin sesli okunacak. Asla madde isareti, yildiz, kalin yazi, tablo, URL veya emoji kullanma.
3. 3-6 cumle arasinda tut.
4. Doktor veya diyetisyen degilsin. Her tavsiyenin sonuna "Bu bir tavsiyedir, doktoruna danismayi unutma." ekle.
5. Asla dozaj degisikligi onerme. Doktor recetesine uymasini soyle.
6. Sadece saglik konularinda konus. Alakasiz konu acilirsa nazikce geri getir.
''';

  static const String _foodAnalysisPrompt = '''
Sen Sofia. Yemek fotograflarini analiz edip diyabet hastasi icin besin degerlerini tahmin ediyorsun.
1. Karbonhidrat miktarini ve yaklasik kalorisini tahmin et.
2. Diyabet icin riskli durum varsa uyar.
3. Asla liste veya tablo yapma. Akici tek paragraf kur.
4. "tahminen", "yaklasik" kelimelerini kullan.
5. Sonuna "Insulin dozunu buna gore ayarlamayi unutma. Doktoruna danis." ekle.
''';

  static const String _biohackingPrompt = '''
Sen Sofia, bir Biohacking Kocusun. Saglik performansini analiz ediyorsun.
1. Verilere bak: ilac uyumu, olcum sikligi, performans.
2. Basari yuksekse "Biohacker", "Irade Makinesi", "Saglik Savascisi" gibi terimlerle ov.
3. Basari dusukse yargilamadan motive edici konus.
4. Emoji kullanma. Kisa ve vurucu konus.
5. Motive edici bir cumleyle bitir.
''';

  static const String _emergencyPrompt = '''
Sen Sofia. ACIL DURUM MODASIN.
Hipoglisemi veya fenalık geciren kullaniciyi uyanik tutmak ve sakinlestirmek.
1. Cok kisa, net ve emir kipiyle konus.
2. Soru sorarak bilincini acik tutmaya calis.
3. Panik yapma, guven verici ve otoriter ol.
4. Sekerli bir seyler almasini soyle.
5. Yardim yolda oldugunu belirt.
''';

  static const String _doctorReportPrompt = '''
Sen Sofia. Ham saglik verilerini doktorlarin okuyacagi profesyonel, tibbi bir ozet raporuna donusturuyorsun.
1. Dil: Resmi, tibbi ve objektif Turkce.
2. "Ben" veya "Sen" kullanma. "Hasta" de.
3. Istatistikleri yorumla.
4. PDF'e yazilacak, paragraf yapisi kur.
5. Profesyonel kapanisla bitir.
''';

  static const String _drugInteractionPrompt = '''
Sen Sofia. Farmakolojik etkilesim kontrolu yapiyorsun.
1. Mevcut ilaclar ile yeni maddeyi karsilastir.
2. Ciddi etkilesim varsa net uyar.
3. Etkilesim yoksa "Bilinen bir etkilesim yok ama doktoruna danis." de.
4. Kisa ve anlasilir ol.
5. Asla ilac onerme veya degistirme.
''';

  static const String _arFoodPrompt = '''
Sen Sofia AI. Kullanici su an AR kamerasyla bir besine bakiyor.
Gorevin, kameranin tespit ettigi besinin diyabet uzerindeki etkisini hizli ve vurucu bir sekilde sesli olarak bildirmektir.
Kurallar:
1. Tahmini kalori ve seker miktarini soyle.
2. Glisemik indeksi yuksekse net bir dille uyar.
3. Uzun paragraflar kurma, aksiyon odakli ol. Ornek: "Bunun yerine sunu tercih edebilirsin".
4. Markdown veya sembol kullanma.
5. 3-5 cumle ile sinirli tut.
''';

  // ─── Konuşma Geçmişi ───────────────────────────────────
  final List<Map<String, dynamic>> _history = [];
  static const int _maxHistory = 20;

  void clearHistory() => _history.clear();

  // ─── Gemini API ─────────────────────────────────────────

  Future<String> _callGemini({
    required String systemPrompt,
    required List<Map<String, dynamic>> contents,
    int maxTokens = 400,
    double temperature = 0.7,
    String? model,
  }) async {
    final useModel = model ?? _model;
    final url = '$_baseUrl/$useModel:generateContent?key=$_apiKey';

    try {
      final body = <String, dynamic>{
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        },
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String? ?? '';
            if (text.isNotEmpty) return text.trim();
          }
        }
        return 'Sofia su an yanit veremedi. Tekrar dene.';
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final msg = data['error']?['message'] ?? '';
        if (msg.toString().contains('API_KEY')) {
          return 'API anahtari gecersiz. Ayarlardan kontrol et.';
        }
        return 'Istek hatasi. Farkli model deneyebilirsin.';
      } else if (response.statusCode == 403) {
        return 'API anahtari yetkisiz. Ayarlardan kontrol et.';
      } else if (response.statusCode == 429) {
        return 'Cok fazla istek. Biraz bekle ve tekrar dene.';
      } else {
        AppLogger.instance.error(
          'Gemini ${response.statusCode}: ${response.body}',
        );
        return 'Baglanti hatasi (${response.statusCode}). Tekrar dene.';
      }
    } catch (e, stack) {
      AppLogger.instance.error('Sofia istisna', error: e, stack: stack);
      final msg = e.toString();
      if (msg.contains('TimeoutException')) {
        return 'Baglanti zaman asimi. Internetini kontrol et.';
      }
      if (msg.contains('SocketException') || msg.contains('OS Error')) {
        return 'Internet baglantisi yok. WiFi veya mobil veriyi kontrol et.';
      }
      return 'Hata: ${e.runtimeType}. Tekrar dene.';
    }
  }

  // ─── Sohbet ─────────────────────────────────────────────

  Future<String> ask(String userMessage) async {
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userMessage},
      ],
    });
    if (_history.length > _maxHistory) {
      _history.removeRange(0, _history.length - _maxHistory);
    }

    final response = await _callGemini(
      systemPrompt: _systemPrompt,
      contents: _history,
    );

    _history.add({
      'role': 'model',
      'parts': [
        {'text': response},
      ],
    });
    return response;
  }

  // ─── Gören Sofia (Yemek Analizi) ───────────────────────

  Future<String> analyzeFood(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final contents = [
      {
        'role': 'user',
        'parts': [
          {
            'text':
                'Bu tabaktaki yemegi analiz et. Karbonhidrat ve kalori tahmin et. Kan sekerimi hizla yukseltir mi?',
          },
          {
            'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
          },
        ],
      },
    ];
    return _callGemini(
      systemPrompt: _foodAnalysisPrompt,
      contents: contents,
      maxTokens: 500,
    );
  }

  // ─── Biohacking ────────────────────────────────────────

  Future<String> analyzeBiohacking({
    required int ilacUyumYuzde,
    required int olcumSayisi,
    required int toplamKayit,
    double? ortalamaGlukoz,
  }) async {
    final prompt =
        'Ilac Alma Orani: %$ilacUyumYuzde, Olcum Sayisi: $olcumSayisi kez, '
        'Toplam Kayit: $toplamKayit'
        '${ortalamaGlukoz != null ? ', Ortalama: ${ortalamaGlukoz.toStringAsFixed(0)} mg/dL' : ''}. '
        'Haftalik degerlendirme yap.';

    return _callGemini(
      systemPrompt: _biohackingPrompt,
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    );
  }

  // ─── Acil Durum ────────────────────────────────────────

  Future<String> emergencyResponse() async {
    return _callGemini(
      systemPrompt: _emergencyPrompt,
      contents: [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'Kullanici panik butonuna basti! Konumunu yakinlarina SMS olarak attim. Kullaniciyla konus ve yonlendir.',
            },
          ],
        },
      ],
      temperature: 0.3,
      maxTokens: 200,
    );
  }

  // ─── Doktor Raporu ─────────────────────────────────────

  Future<String> generateDoctorReport({
    required String hastaAdi,
    required int toplamKayit,
    required double ortalamaAclik,
    required int hipoSayisi,
    required int atlananGun,
    String? ea1c,
  }) async {
    final prompt =
        'Hasta: $hastaAdi. Son 30 Gun: Ort. Aclik ${ortalamaAclik.toStringAsFixed(0)} mg/dL, '
        'Kayit: $toplamKayit, Hipo: $hipoSayisi kez, Atlanan: $atlananGun gun'
        '${ea1c != null ? ', eA1c: %$ea1c' : ''}. Doktor icin ozetle.';

    return _callGemini(
      systemPrompt: _doctorReportPrompt,
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      temperature: 0.3,
      maxTokens: 600,
    );
  }

  // ─── İlaç Etkileşim ───────────────────────────────────

  Future<String> checkDrugInteraction({
    required List<String> mevcutIlaclar,
    required String yeniMadde,
  }) async {
    final prompt =
        'Mevcut Ilaclar: ${mevcutIlaclar.join(", ")}. '
        'Yeni: $yeniMadde. Riskli mi?';

    return _callGemini(
      systemPrompt: _drugInteractionPrompt,
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      temperature: 0.3,
    );
  }

  // ─── Kan Şekeri Analizi ────────────────────────────────

  Future<String> analyzeGlucose({
    required double avgGlucose,
    required int recordCount,
    String? ea1c,
    String? stabilityLevel,
    int? todayFasting,
    int? todayPostprandial,
  }) async {
    final buf = StringBuffer('Kan sekeri verileri: ');
    buf.write('$recordCount kayit, ort ${avgGlucose.toStringAsFixed(0)} mg/dL');
    if (ea1c != null) buf.write(', eA1c: %$ea1c');
    if (stabilityLevel != null) buf.write(', stabilite: $stabilityLevel');
    if (todayFasting != null) buf.write(', bugun aclik: $todayFasting');
    if (todayPostprandial != null)
      buf.write(', bugun tokluk: $todayPostprandial');
    buf.write('. Degerlendir ve beslenme tavsiyesi ver.');
    return ask(buf.toString());
  }

  Future<String> askDrugInfo(String drugName) async {
    return ask('$drugName ilaci hakkinda bilgi ver. Diyabete etkisini belirt.');
  }

  // ─── AR Kamera Besin Analizi ──────────────────────────────

  Future<String> analyzeDetectedFood({
    required String foodName,
    required int calories,
    required int carbsG,
    required int glycemicIndex,
    int? lastGlucose,
  }) async {
    final prompt = StringBuffer();
    prompt.write('Kamera Tespiti: 1 Porsiyon $foodName. ');
    prompt.write('Kalori: $calories kcal, Karbonhidrat: ${carbsG}g, ');
    prompt.write('Glisemik Indeks: $glycemicIndex. ');
    if (lastGlucose != null) {
      prompt.write('Kullanicinin Son Seker Olcumu: $lastGlucose mg/dL. ');
    }
    prompt.write(
      'Kullaniciya bu yemegi yiyip yememesi gerektigini kisa bir sesli brifing seklinde sun.',
    );

    return _callGemini(
      systemPrompt: _arFoodPrompt,
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': prompt.toString()},
          ],
        },
      ],
      temperature: 0.5,
      maxTokens: 300,
    );
  }

  Future<String> askNutritionAdvice(String question) async {
    return ask('Beslenme sorusu: $question. Diyabet hastasina tavsiye ver.');
  }
}

class SofiaModel {
  final String id;
  final String name;
  const SofiaModel({required this.id, required this.name});
}
