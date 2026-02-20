/// Prediktif Glisemik Etki Motoru — Türk Gıda Veritabanı + Simülasyon.
///
/// Kullanıcı yediği yemeği girdiğinde: emilim hızını, insülin yanıtını,
/// pik zamanını simüle eder ve dengeleyici egzersiz önerisi sunar.
library;

import 'dart:math';

// ─── Veri Modelleri ────────────────────────────────────────────

enum AbsorptionRate { slow, medium, fast }
enum PortionSize { small, normal, large }

class TurkishFoodItem {
  final String name;
  final String emoji;
  final int glycemicIndex; // 0-100
  final double carbsPer100g; // gram
  final int caloriesPer100g;
  final double defaultPortionG; // gram
  final AbsorptionRate absorption;
  final String category;

  const TurkishFoodItem({
    required this.name,
    required this.emoji,
    required this.glycemicIndex,
    required this.carbsPer100g,
    required this.caloriesPer100g,
    required this.defaultPortionG,
    required this.absorption,
    required this.category,
  });

  double get glycemicLoad =>
      (glycemicIndex * carbsPer100g * defaultPortionG) / (100 * 100);
}

class GlycemicPrediction {
  final TurkishFoodItem food;
  final PortionSize portion;
  final double glycemicLoad;
  final int peakMinutes;
  final int estimatedRiseMgDl;
  final AbsorptionRate absorptionRate;
  final String exerciseType;
  final int exerciseMinutes;
  final String summary;
  final String detailedAdvice;

  const GlycemicPrediction({
    required this.food,
    required this.portion,
    required this.glycemicLoad,
    required this.peakMinutes,
    required this.estimatedRiseMgDl,
    required this.absorptionRate,
    required this.exerciseType,
    required this.exerciseMinutes,
    required this.summary,
    required this.detailedAdvice,
  });
}

// ─── Motor ─────────────────────────────────────────────────────

class GlycemicEngine {
  GlycemicEngine._();
  static final GlycemicEngine instance = GlycemicEngine._();

  /// Porsiyon çarpanları.
  static double portionMultiplier(PortionSize p) {
    switch (p) {
      case PortionSize.small:
        return 0.6;
      case PortionSize.normal:
        return 1.0;
      case PortionSize.large:
        return 1.5;
    }
  }

  /// Yemek adıyla arama (fuzzy).
  List<TurkishFoodItem> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().replaceAll('ı', 'i').replaceAll('ş', 's');
    return turkishFoods.where((f) {
      final name = f.name.toLowerCase().replaceAll('ı', 'i').replaceAll('ş', 's');
      return name.contains(q) || f.category.toLowerCase().contains(q);
    }).toList();
  }

  /// ML Kit etiketinden yemek eşleştirme.
  TurkishFoodItem? matchFromLabel(String label) {
    final q = label.toLowerCase().trim();

    // Direkt eşleşme
    for (final f in turkishFoods) {
      if (f.name.toLowerCase() == q) return f;
    }

    // İngilizce → Türkçe eşleşme haritası
    final labelMap = <String, String>{
      'bread': 'Beyaz Ekmek',
      'rice': 'Pirinç Pilavı',
      'pasta': 'Makarna',
      'apple': 'Elma',
      'banana': 'Muz',
      'orange': 'Portakal',
      'yogurt': 'Yoğurt',
      'cheese': 'Beyaz Peynir',
      'egg': 'Yumurta',
      'chicken': 'Tavuk Göğsü',
      'meat': 'Kırmızı Et',
      'salad': 'Yeşil Salata',
      'soup': 'Mercimek Çorbası',
      'cookie': 'Bisküvi',
      'cake': 'Pasta/Kek',
      'chocolate': 'Çikolata',
      'honey': 'Bal',
      'milk': 'Süt',
      'tea': 'Çay',
      'coffee': 'Türk Kahvesi',
      'pizza': 'Pizza',
      'french fries': 'Patates Kızartması',
      'croissant': 'Kruvasan',
      'ice cream': 'Dondurma',
      'watermelon': 'Karpuz',
      'grapes': 'Üzüm',
      'lentil': 'Mercimek Çorbası',
      'baklava': 'Baklava',
      'pastry': 'Börek',
    };

    final mapped = labelMap[q];
    if (mapped != null) {
      for (final f in turkishFoods) {
        if (f.name == mapped) return f;
      }
    }

    // Kısmi eşleşme
    for (final f in turkishFoods) {
      if (f.name.toLowerCase().contains(q) || q.contains(f.name.toLowerCase())) {
        return f;
      }
    }
    return null;
  }

  /// Glisemik etki tahmini hesapla.
  GlycemicPrediction predict(TurkishFoodItem food, PortionSize portion) {
    final mult = portionMultiplier(portion);
    final actualCarbs = food.carbsPer100g * (food.defaultPortionG / 100) * mult;
    final gl = (food.glycemicIndex * actualCarbs) / 100;

    // Pik zamanı: GI'ye bağlı
    final peakMin = food.absorption == AbsorptionRate.fast
        ? 30
        : food.absorption == AbsorptionRate.medium
            ? 45
            : 60;

    // Tahmini artış: ~3-5 mg/dL per gram carb (GI'ye bağlı)
    final riseFactor = food.glycemicIndex > 70
        ? 4.5
        : food.glycemicIndex > 55
            ? 3.5
            : 2.5;
    final rise = (actualCarbs * riseFactor).round();

    // Egzersiz önerisi: GL bazlı
    String exerciseType;
    int exerciseMin;
    if (gl > 20) {
      exerciseType = 'tempolu yürüyüş veya bisiklet';
      exerciseMin = min(45, (gl * 1.5).round());
    } else if (gl > 10) {
      exerciseType = 'hafif tempolu yürüyüş';
      exerciseMin = min(30, (gl * 1.2).round());
    } else {
      exerciseType = 'kısa bir yürüyüş';
      exerciseMin = max(10, (gl * 1.0).round());
    }

    // Porsiyon etiketi
    final portionLabel = portion == PortionSize.small
        ? 'küçük'
        : portion == PortionSize.large
            ? 'büyük'
            : 'normal';

    // Özet
    final summary =
        '${food.emoji} $portionLabel porsiyon ${food.name} önümüzdeki '
        '$peakMin dakika içinde kan şekerini ~$rise mg/dL artırabilir.';

    // Detaylı tavsiye
    final buf = StringBuffer();
    buf.write('Bu porsiyon yaklaşık ${actualCarbs.toStringAsFixed(0)}g karbonhidrat ');
    buf.write('ve ${(food.caloriesPer100g * food.defaultPortionG / 100 * mult).round()} kcal içeriyor. ');

    if (food.glycemicIndex > 70) {
      buf.write('Glisemik indeksi yüksek, kana hızla karışır. ');
    } else if (food.glycemicIndex > 55) {
      buf.write('Orta glisemik indeksli, kontrollü yükseliş yapar. ');
    } else {
      buf.write('Düşük glisemik indeksli, yavaş emilir. ');
    }

    buf.write('$exerciseMin dakika $exerciseType yaparak bu glisemik yükü ');
    buf.write('kaslarında yakarak dengeleyebilirsin.');

    return GlycemicPrediction(
      food: food,
      portion: portion,
      glycemicLoad: gl,
      peakMinutes: peakMin,
      estimatedRiseMgDl: rise,
      absorptionRate: food.absorption,
      exerciseType: exerciseType,
      exerciseMinutes: exerciseMin,
      summary: summary,
      detailedAdvice: buf.toString(),
    );
  }

  // ─── Türk Gıda Veritabanı ─────────────────────────────────

  static const List<TurkishFoodItem> turkishFoods = [
    // ── Ekmek & Hamur İşi ──
    TurkishFoodItem(
      name: 'Beyaz Ekmek', emoji: '🍞', glycemicIndex: 75,
      carbsPer100g: 49, caloriesPer100g: 265, defaultPortionG: 50,
      absorption: AbsorptionRate.fast, category: 'Ekmek',
    ),
    TurkishFoodItem(
      name: 'Tam Buğday Ekmek', emoji: '🍞', glycemicIndex: 50,
      carbsPer100g: 42, caloriesPer100g: 247, defaultPortionG: 50,
      absorption: AbsorptionRate.medium, category: 'Ekmek',
    ),
    TurkishFoodItem(
      name: 'Simit', emoji: '🥯', glycemicIndex: 72,
      carbsPer100g: 55, caloriesPer100g: 310, defaultPortionG: 120,
      absorption: AbsorptionRate.fast, category: 'Ekmek',
    ),
    TurkishFoodItem(
      name: 'Börek', emoji: '🥧', glycemicIndex: 65,
      carbsPer100g: 35, caloriesPer100g: 290, defaultPortionG: 150,
      absorption: AbsorptionRate.medium, category: 'Hamur İşi',
    ),
    TurkishFoodItem(
      name: 'Lahmacun', emoji: '🫓', glycemicIndex: 68,
      carbsPer100g: 38, caloriesPer100g: 270, defaultPortionG: 180,
      absorption: AbsorptionRate.medium, category: 'Hamur İşi',
    ),
    TurkishFoodItem(
      name: 'Pide', emoji: '🫓', glycemicIndex: 70,
      carbsPer100g: 42, caloriesPer100g: 280, defaultPortionG: 200,
      absorption: AbsorptionRate.fast, category: 'Hamur İşi',
    ),
    TurkishFoodItem(
      name: 'Kruvasan', emoji: '🥐', glycemicIndex: 67,
      carbsPer100g: 46, caloriesPer100g: 406, defaultPortionG: 60,
      absorption: AbsorptionRate.fast, category: 'Hamur İşi',
    ),
    TurkishFoodItem(
      name: 'Pizza', emoji: '🍕', glycemicIndex: 60,
      carbsPer100g: 33, caloriesPer100g: 266, defaultPortionG: 200,
      absorption: AbsorptionRate.medium, category: 'Hamur İşi',
    ),

    // ── Pirinç & Makarna ──
    TurkishFoodItem(
      name: 'Pirinç Pilavı', emoji: '🍚', glycemicIndex: 73,
      carbsPer100g: 28, caloriesPer100g: 130, defaultPortionG: 200,
      absorption: AbsorptionRate.fast, category: 'Tahıl',
    ),
    TurkishFoodItem(
      name: 'Bulgur Pilavı', emoji: '🍚', glycemicIndex: 48,
      carbsPer100g: 18, caloriesPer100g: 83, defaultPortionG: 200,
      absorption: AbsorptionRate.slow, category: 'Tahıl',
    ),
    TurkishFoodItem(
      name: 'Makarna', emoji: '🍝', glycemicIndex: 55,
      carbsPer100g: 31, caloriesPer100g: 157, defaultPortionG: 200,
      absorption: AbsorptionRate.medium, category: 'Tahıl',
    ),

    // ── Çorbalar ──
    TurkishFoodItem(
      name: 'Mercimek Çorbası', emoji: '🍲', glycemicIndex: 44,
      carbsPer100g: 12, caloriesPer100g: 60, defaultPortionG: 300,
      absorption: AbsorptionRate.slow, category: 'Çorba',
    ),
    TurkishFoodItem(
      name: 'Tarhana Çorbası', emoji: '🍲', glycemicIndex: 55,
      carbsPer100g: 14, caloriesPer100g: 65, defaultPortionG: 300,
      absorption: AbsorptionRate.medium, category: 'Çorba',
    ),
    TurkishFoodItem(
      name: 'Ezogelin Çorbası', emoji: '🍲', glycemicIndex: 50,
      carbsPer100g: 13, caloriesPer100g: 62, defaultPortionG: 300,
      absorption: AbsorptionRate.medium, category: 'Çorba',
    ),

    // ── Et & Protein ──
    TurkishFoodItem(
      name: 'Tavuk Göğsü', emoji: '🍗', glycemicIndex: 0,
      carbsPer100g: 0, caloriesPer100g: 165, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Et',
    ),
    TurkishFoodItem(
      name: 'Kırmızı Et', emoji: '🥩', glycemicIndex: 0,
      carbsPer100g: 0, caloriesPer100g: 250, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Et',
    ),
    TurkishFoodItem(
      name: 'Köfte', emoji: '🧆', glycemicIndex: 15,
      carbsPer100g: 5, caloriesPer100g: 235, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Et',
    ),
    TurkishFoodItem(
      name: 'Yumurta', emoji: '🥚', glycemicIndex: 0,
      carbsPer100g: 1, caloriesPer100g: 155, defaultPortionG: 100,
      absorption: AbsorptionRate.slow, category: 'Protein',
    ),
    TurkishFoodItem(
      name: 'Balık', emoji: '🐟', glycemicIndex: 0,
      carbsPer100g: 0, caloriesPer100g: 206, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Et',
    ),

    // ── Süt Ürünleri ──
    TurkishFoodItem(
      name: 'Yoğurt', emoji: '🥛', glycemicIndex: 36,
      carbsPer100g: 4, caloriesPer100g: 61, defaultPortionG: 200,
      absorption: AbsorptionRate.slow, category: 'Süt Ürünü',
    ),
    TurkishFoodItem(
      name: 'Ayran', emoji: '🥛', glycemicIndex: 30,
      carbsPer100g: 2, caloriesPer100g: 40, defaultPortionG: 250,
      absorption: AbsorptionRate.slow, category: 'Süt Ürünü',
    ),
    TurkishFoodItem(
      name: 'Beyaz Peynir', emoji: '🧀', glycemicIndex: 0,
      carbsPer100g: 1, caloriesPer100g: 264, defaultPortionG: 60,
      absorption: AbsorptionRate.slow, category: 'Süt Ürünü',
    ),
    TurkishFoodItem(
      name: 'Süt', emoji: '🥛', glycemicIndex: 31,
      carbsPer100g: 5, caloriesPer100g: 42, defaultPortionG: 200,
      absorption: AbsorptionRate.slow, category: 'Süt Ürünü',
    ),

    // ── Meyveler ──
    TurkishFoodItem(
      name: 'Elma', emoji: '🍎', glycemicIndex: 36,
      carbsPer100g: 14, caloriesPer100g: 52, defaultPortionG: 180,
      absorption: AbsorptionRate.slow, category: 'Meyve',
    ),
    TurkishFoodItem(
      name: 'Muz', emoji: '🍌', glycemicIndex: 51,
      carbsPer100g: 23, caloriesPer100g: 89, defaultPortionG: 120,
      absorption: AbsorptionRate.medium, category: 'Meyve',
    ),
    TurkishFoodItem(
      name: 'Portakal', emoji: '🍊', glycemicIndex: 43,
      carbsPer100g: 12, caloriesPer100g: 47, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Meyve',
    ),
    TurkishFoodItem(
      name: 'Karpuz', emoji: '🍉', glycemicIndex: 76,
      carbsPer100g: 8, caloriesPer100g: 30, defaultPortionG: 300,
      absorption: AbsorptionRate.fast, category: 'Meyve',
    ),
    TurkishFoodItem(
      name: 'Üzüm', emoji: '🍇', glycemicIndex: 59,
      carbsPer100g: 18, caloriesPer100g: 69, defaultPortionG: 150,
      absorption: AbsorptionRate.medium, category: 'Meyve',
    ),
    TurkishFoodItem(
      name: 'Çilek', emoji: '🍓', glycemicIndex: 40,
      carbsPer100g: 8, caloriesPer100g: 32, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Meyve',
    ),

    // ── Sebzeler ──
    TurkishFoodItem(
      name: 'Yeşil Salata', emoji: '🥗', glycemicIndex: 15,
      carbsPer100g: 2, caloriesPer100g: 15, defaultPortionG: 150,
      absorption: AbsorptionRate.slow, category: 'Sebze',
    ),
    TurkishFoodItem(
      name: 'Patates Kızartması', emoji: '🍟', glycemicIndex: 75,
      carbsPer100g: 37, caloriesPer100g: 312, defaultPortionG: 200,
      absorption: AbsorptionRate.fast, category: 'Sebze',
    ),

    // ── Tatlılar & Şekerli ──
    TurkishFoodItem(
      name: 'Baklava', emoji: '🍯', glycemicIndex: 85,
      carbsPer100g: 50, caloriesPer100g: 428, defaultPortionG: 80,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Helva', emoji: '🍯', glycemicIndex: 70,
      carbsPer100g: 52, caloriesPer100g: 469, defaultPortionG: 50,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Ballı Tahin', emoji: '🍯', glycemicIndex: 75,
      carbsPer100g: 55, caloriesPer100g: 450, defaultPortionG: 40,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Sütlaç', emoji: '🍮', glycemicIndex: 65,
      carbsPer100g: 20, caloriesPer100g: 130, defaultPortionG: 200,
      absorption: AbsorptionRate.medium, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Dondurma', emoji: '🍦', glycemicIndex: 61,
      carbsPer100g: 24, caloriesPer100g: 207, defaultPortionG: 100,
      absorption: AbsorptionRate.medium, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Çikolata', emoji: '🍫', glycemicIndex: 49,
      carbsPer100g: 60, caloriesPer100g: 546, defaultPortionG: 40,
      absorption: AbsorptionRate.medium, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Pasta/Kek', emoji: '🎂', glycemicIndex: 72,
      carbsPer100g: 52, caloriesPer100g: 350, defaultPortionG: 100,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Bisküvi', emoji: '🍪', glycemicIndex: 69,
      carbsPer100g: 68, caloriesPer100g: 480, defaultPortionG: 30,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Bal', emoji: '🍯', glycemicIndex: 87,
      carbsPer100g: 82, caloriesPer100g: 304, defaultPortionG: 20,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Lokum', emoji: '🍬', glycemicIndex: 82,
      carbsPer100g: 90, caloriesPer100g: 365, defaultPortionG: 30,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),
    TurkishFoodItem(
      name: 'Künefe', emoji: '🧁', glycemicIndex: 78,
      carbsPer100g: 45, caloriesPer100g: 390, defaultPortionG: 150,
      absorption: AbsorptionRate.fast, category: 'Tatlı',
    ),

    // ── İçecekler ──
    TurkishFoodItem(
      name: 'Çay', emoji: '🍵', glycemicIndex: 0,
      carbsPer100g: 0, caloriesPer100g: 1, defaultPortionG: 200,
      absorption: AbsorptionRate.slow, category: 'İçecek',
    ),
    TurkishFoodItem(
      name: 'Türk Kahvesi', emoji: '☕', glycemicIndex: 0,
      carbsPer100g: 0, caloriesPer100g: 2, defaultPortionG: 80,
      absorption: AbsorptionRate.slow, category: 'İçecek',
    ),
    TurkishFoodItem(
      name: 'Meyve Suyu', emoji: '🧃', glycemicIndex: 66,
      carbsPer100g: 11, caloriesPer100g: 46, defaultPortionG: 250,
      absorption: AbsorptionRate.fast, category: 'İçecek',
    ),
    TurkishFoodItem(
      name: 'Gazlı İçecek', emoji: '🥤', glycemicIndex: 63,
      carbsPer100g: 11, caloriesPer100g: 42, defaultPortionG: 330,
      absorption: AbsorptionRate.fast, category: 'İçecek',
    ),

    // ── Kuruyemiş ──
    TurkishFoodItem(
      name: 'Ceviz', emoji: '🥜', glycemicIndex: 15,
      carbsPer100g: 14, caloriesPer100g: 654, defaultPortionG: 30,
      absorption: AbsorptionRate.slow, category: 'Kuruyemiş',
    ),
    TurkishFoodItem(
      name: 'Badem', emoji: '🥜', glycemicIndex: 15,
      carbsPer100g: 22, caloriesPer100g: 579, defaultPortionG: 30,
      absorption: AbsorptionRate.slow, category: 'Kuruyemiş',
    ),
    TurkishFoodItem(
      name: 'Kuru Kayısı', emoji: '🍑', glycemicIndex: 35,
      carbsPer100g: 63, caloriesPer100g: 241, defaultPortionG: 40,
      absorption: AbsorptionRate.medium, category: 'Kuruyemiş',
    ),
    TurkishFoodItem(
      name: 'Hurma', emoji: '🌴', glycemicIndex: 55,
      carbsPer100g: 75, caloriesPer100g: 282, defaultPortionG: 30,
      absorption: AbsorptionRate.medium, category: 'Meyve',
    ),
  ];
}
