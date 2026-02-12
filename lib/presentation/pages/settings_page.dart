import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../app/theme.dart';
import '../widgets/rootcastle_app_bar.dart';

/// Ayarlar ve Kullanım Kılavuzu sayfası.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RootcastleAppBar(title: Tr.ayarlar),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Kullanım Kılavuzu ──────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: RootcastleColors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Tr.kullanimKilavuzu,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: RootcastleColors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _guideSection(
                    '1. Yeni Kayıt Ekleme',
                    'Ana sayfadan "Yeni Kayıt Ekle" butonuna tıklayın. Tarih seçin, '
                        'ölçüm değerlerinizi (sabah açlık, tokluk vb.) girin ve kaydedin. '
                        'En az bir ölçüm alanı doldurulmalıdır.',
                  ),
                  _guideSection(
                    '2. Tokluk Hatırlatıcısı',
                    'Bir açlık değeri girdikten sonra uygulama size "Tokluk hatırlatıcısı '
                        'kurulsun mu?" diye soracaktır. Onaylarsanız 2 saat sonra bildirim '
                        'alırsınız.',
                  ),
                  _guideSection(
                    '3. Kayıtları Görüntüleme',
                    '"Kayıtlar" sayfasında tüm ölçümlerinizi tablo halinde görüntüleyin. '
                        'Tarih aralığı filtresi ile istediğiniz döneme ait verileri '
                        'inceleyebilirsiniz.',
                  ),
                  _guideSection(
                    '4. Tahmini HbA1c (eA1c)',
                    'Ana sayfada son 90 günlük verilerinize göre tahmini HbA1c değeri '
                        'hesaplanır. En az 15 kayıt gereklidir. Bu değer laboratuvar '
                        'sonucu yerine geçmez.',
                  ),
                  _guideSection(
                    '5. Stabilite Göstergesi',
                    'Glukoz değerlerinizdeki dalgalanma standart sapma (SD) ile ölçülür. '
                        'Yeşil = Stabil, Sarı = Orta, Kırmızı = Yüksek değişkenlik.',
                  ),
                  _guideSection(
                    '6. Dışa Aktarma',
                    'Verilerinizi CSV, Excel (XLSX), JSON veya profesyonel PDF rapor '
                        'olarak dışa aktarabilirsiniz. PDF rapor doktorunuza göstermek '
                        'için idealdir.',
                  ),
                  _guideSection(
                    '7. İçe Aktarma',
                    'JSON yedek dosyanızı geri yükleyebilirsiniz. Dosya bütünlüğü '
                        'SHA-256 checksum ile doğrulanır.',
                  ),
                  _guideSection(
                    '8. Kişisel Bilgiler',
                    'İsim, yaş, kilo, doktor ve hemşire bilgilerinizi girin. Bu '
                        'veriler PDF raporunuzda kullanılır.',
                  ),
                  _guideSection(
                    '9. İdeal Hedefler',
                    'Diyabet için ideal kan şekeri aralıklarını görüntüleyin. '
                        'Açlık < 100 mg/dL, Tokluk < 140 mg/dL.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Sıkça Sorulan Sorular ─────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sık Sorulan Sorular',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: RootcastleColors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _faqTile(
                    'Verilerim güvende mi?',
                    'Evet. Tüm verileriniz cihazınızda saklanır, hiçbir sunucuya '
                        'gönderilmez. Yedeklemeler SHA-256 ile korunur.',
                  ),
                  _faqTile(
                    'İnternet bağlantısı gerekli mi?',
                    'Hayır. Uygulama tamamen çevrimdışı çalışır.',
                  ),
                  _faqTile(
                    'eA1c nedir?',
                    'Tahmini HbA1c, son 90 günlük ortalama kan şekeri değerinize göre '
                        'hesaplanan bir göstergedir. Laboratuvar sonucu yerine geçmez.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _guideSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: RootcastleColors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  static Widget _faqTile(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(answer, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
